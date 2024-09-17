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

  def generate_key(ticket, owner \\ nil) do
    case owner do
      nil -> "#{@ttl_expire_key_prefix}#{ticket}"
      _ -> "#{@ttl_expire_key_prefix}#{owner}:#{ticket}"
    end
  end

  def generate_value(ticket, owner \\ nil) do
    case owner do
      nil -> "#{ticket}"
      _ -> "#{owner}:#{ticket}"
    end
  end

  def set_timeLock(owner, ticket, lifetime) do
    key = generate_key(ticket, owner)
    value = generate_value(ticket, owner)

    Redix.command(:redix, ["SET", key, value, "EX", Integer.to_string(lifetime)])
    |> case do
         {:ok, "OK"} -> :ok
         error -> {:error, "Failed to set_timeLock: #{inspect(error)}"}
       end
  end

  def set_noTimeLock(owner, ticket) do
    key = generate_key(ticket, owner)
    value = generate_value(ticket, owner)

    Redix.command(:redix, ["SET", key, value])
    |> case do
         {:ok, "OK"} -> :ok
         error -> {:error, "Failed to set_noTimeLock: #{inspect(error)}"}
       end
  end

  def set_timeLock_notExists(owner, ticket, lifetime) do
    key = generate_key(ticket, owner)
    value = generate_value(ticket, owner)

    Redix.command(:redix, ["SETNX", key, value])
    |> case do
         {:ok, 1} ->
           Redix.command(:redix, ["EXPIRE", key, Integer.to_string(lifetime)])
           :ok
         {:ok, 0} -> {:error, "Key already exists"}
         error -> {:error, "Failed to set_timeLock_notExists: #{inspect(error)}"}
       end
  end

  def set_timeLock_force(owner, ticket, lifetime) do
    key = generate_key(ticket, owner)
    value = generate_value(ticket, owner)

    Redix.command(:redix, ["SET", key, value, "EX", Integer.to_string(lifetime)])
    |> case do
         {:ok, "OK"} -> :ok
         error -> {:error, "Failed to acquire lock: #{inspect(error)}"}
       end
  end

  def get_lock_value(owner, ticket) do
    key = generate_key(ticket, owner)

    Redix.command(:redix, ["GET", key])
    |> case do
         {:ok, nil} -> {:error, "Key not found"}
         {:ok, value} -> {:ok, value}
         error -> {:error, "Failed to get value: #{inspect(error)}"}
       end
  end

  def release_lock(ticket, owner) do
    key = generate_key(ticket, owner)

    Redix.command(:redix, ["DEL", key])
    |> case do
         {:ok, 1} -> :ok  # 1 означает, что ключ был удален
         {:ok, 0} -> {:error, :not_found}  # 0 означает, что ключ не был найден
         error -> {:error, "Failed to release_lock: #{inspect(error)}"}
       end
  end
end