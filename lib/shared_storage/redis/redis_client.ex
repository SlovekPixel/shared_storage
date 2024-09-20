defmodule SharedStorage.Redis.RedisClient do
  use GenServer

  @ttl_expire_key_prefix "lock:"

  def start_link(_opts) do
    Redix.start_link(
      host: "127.0.0.1",
      port: 6379,
      name: :redix
    )
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # Checking to verify that Redis is accessible.
  def check_connection do
    case Redix.command(:redix, ["PING"]) do
      {:ok, "PONG"} ->
        IO.puts("Successfully connected to Redis!")
        :ok
      {:error, reason} ->
        IO.puts("Failed to connect to Redis: #{inspect(reason)}")
        :error
    end
  end

  # Generate a key or pattern for Redis.
  def generate_key(ticket \\ nil, owner \\ nil) do
    case {ticket, owner} do
      {nil, nil} ->
        {:error, "It needs at least one value."}

      {nil, owner} when is_binary(owner) ->
        {:ok, "#{@ttl_expire_key_prefix}#{owner}:*"}

      {ticket, nil} when is_binary(ticket) ->
        {:ok, "#{@ttl_expire_key_prefix}*:#{ticket}"}

      {ticket, owner} when is_binary(ticket) and is_binary(owner) ->
        {:ok, "#{@ttl_expire_key_prefix}#{owner}:#{ticket}"}

      _ ->
        {:error, "Invalid input."}
    end
  end

  # Generating a value for Redis.
  def generate_value(ticket, owner) do
    case {ticket, owner} do
      {ticket, owner} when is_binary(ticket) and is_binary(owner) ->
        {:ok, "#{owner}:#{ticket}"}

      _ ->
        {:error, "Invalid input."}
    end
  end

  # Exactly set the time lock on the ticket in seconds.
  def set_timeLock_force(owner, ticket, lifetime) do
    case generate_key(ticket, owner) do
      {:ok, key} ->
        case generate_value(ticket, owner) do
          {:ok, value} ->
            Redix.command(:redix, ["SET", key, value, "EX", Integer.to_string(lifetime)])
            |> case do
                 {:ok, _} -> :ok
                 error -> {:error, "Failed to set_timeLock: #{inspect(error)}"}
               end

          {:error, reason} ->
            {:error, "Failed to generate value: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  # Accurately set a permanent lock on the ticket.
  def set_noTimeLock_force(owner, ticket) do
    case generate_key(ticket, owner) do
      {:ok, key} ->
        case generate_value(ticket, owner) do
          {:ok, value} ->
            Redix.command(:redix, ["SET", key, value])
            |> case do
                 {:ok, _} -> {:ok, "OK"}
                 error -> {:error, "Failed to set_noTimeLock: #{inspect(error)}"}
               end

          {:error, reason} ->
            {:error, "Failed to generate value: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  def set_timeLock_notExists(owner, ticket, lifetime) do
    case generate_key(ticket, owner) do
      {:ok, key} ->
        case generate_value(ticket, owner) do
          {:ok, value} ->
            Redix.command(:redix, ["SETNX", key, value])
            |> case do
                 {:ok, 1} ->
                   case Redix.command(:redix, ["EXPIRE", key, Integer.to_string(lifetime)]) do
                     {:ok, 1} -> :ok  # TTL успешно установлен
                     {:ok, 0} -> {:error, "Failed to set TTL"}
                     error -> {:error, "Failed to set TTL: #{inspect(error)}"}
                   end

                 {:ok, 0} -> {:error, "Key already exists"}
                 error -> {:error, "Failed to set_timeLock_notExists: #{inspect(error)}"}
               end

          {:error, reason} ->
            {:error, "Failed to generate value: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  # Get the value of a ticket by key. The owner must match.
  def get_lock_value(owner, ticket) do
    case generate_key(ticket, owner) do
      {:ok, key} ->
        Redix.command(:redix, ["GET", key])
        |> case do
             {:ok, nil} -> {:error, "Key not found"}
             {:ok, value} -> {:ok, value}
             error -> {:error, "Failed to get value: #{inspect(error)}"}
           end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  # Release the lock if the owner is the same.
  def release_lock(ticket, owner) do
    case verify_owner(ticket, owner) do
      :ok ->
        case generate_key(ticket, owner) do
          {:ok, key} ->
            Redix.command(:redix, ["DEL", key])
            |> case do
                 {:ok, 1} -> :ok
                 {:ok, 0} -> {:error, :not_found}
                 error -> {:error, "Failed to release lock: #{inspect(error)}"}
               end

          {:error, reason} ->
            {:error, "Failed to generate key: #{reason}"}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Receive all of the owner's keys.
  def get_keys_by_owner(owner) do
    case generate_key(nil, owner) do
      {:ok, pattern} ->
        Redix.command(:redix, ["KEYS", pattern])
        |> case do
             {:ok, keys} when is_list(keys) and length(keys) > 0 -> {:ok, keys}
             {:ok, []} -> {:error, "No keys found for owner #{owner}"}
             error -> {:error, "Failed to get keys for owner: #{inspect(error)}"}
           end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  def is_ticket_not_locked(ticket) do
    case generate_key(ticket, nil) do
      {:ok, pattern} ->
        case Redix.command(:redix, ["KEYS", pattern]) do
          {:ok, []} ->
            :ok

          {:ok, _keys} ->
            {:error, "Ticket #{ticket} is already locked"}

          error ->
            {:error, "Failed to check keys for ticket #{ticket}: #{inspect(error)}"}
        end

      {:error, reason} ->
               {:error, "Failed to generate key: #{reason}"}
    end
  end

  # Get owner by the ticket.
  def get_owner_by_ticket(ticket) do
    case generate_key(ticket, nil) do
      {:ok, pattern} ->
        case Redix.command(:redix, ["KEYS", pattern]) do
          {:ok, [key]} ->
            Redix.command(:redix, ["GET", key])
            |> case do
                 {:ok, value} when is_binary(value) ->
                   [owner, _] = String.split(value, ":")
                   {:ok, owner}

                 {:error, reason} -> {:error, "Failed to get owner by ticket: #{reason}"}
               end

          {:ok, []} -> {:error, "No owner found for ticket #{ticket}"}
          error -> {:error, "Failed to find key for ticket: #{inspect(error)}"}
        end

      {:error, reason} ->
        {:error, "Failed to generate key: #{reason}"}
    end
  end

  # Checking to verify you're a ticket owner.
  def verify_owner(ticket, owner) do
    case get_owner_by_ticket(ticket) do
      {:ok, ticket_owner} when ticket_owner == owner ->
        {:ok, "Owner verified. Owner: #{owner}"}

      {:ok, _} ->
        {:error, "Owner verification failed. The owner does not match."}

      {:error, reason} ->
        {:error, "Failed to verify owner: #{reason}"}
    end
  end
end