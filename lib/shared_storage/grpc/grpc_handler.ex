defmodule SharedStorage.GRPCHandler do
  alias LockService.{
    LockRequest,
    LockResponse,
    LockRequestNoTime,
    LockResponseNoTime,
    LockRequestList,
    LockResponseList,
    LockRequestNoTimeList,
    LockResponseNoTimeList
    }
  alias SharedStorage.Redis.RedisClient

  # Lock the recording for a period of time if the recording is not locked.
  def acquire_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.set_timeLock(owner, ticket, lifetime) do
      :ok ->
        {:ok, %LockResponse{
          isError: false,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: "acquire_lock successfully."}
        }
      {:error, reason} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: reason}
        }
    end
  end

  # Unlocks the record if the record is locked and owner matches.
  def release_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.release_lock(ticket, owner) do
      :ok ->
        {:ok, %LockResponseNoTime{
          isError: false,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: "Lock released successfully."
        }}

      {:error, :not_found} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: "Lock not found."
        }}

      {:error, reason} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: reason
        }}
    end
  end

  # Lock the record for a period of time, even if it is already locked. But if it is locked, it must match the owner.
  def ensure_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.verify_owner(ticket, owner) do
      :ok ->
        RedisClient.set_timeLock_force(owner, ticket, lifetime)
        {:ok, %LockResponse{
          isError: false,
          lock: %LockRequest{owner: owner, ticket: ticket, lifetime: lifetime},
          message: "Lock ensured successfully."
        }}

      {:error, "Owner mismatch"} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{owner: owner, ticket: ticket, lifetime: lifetime},
          message: "Owner mismatch. Cannot ensure lock for ticket #{ticket}."
        }}

      {:error, _reason} ->
        case RedisClient.set_timeLock(owner, ticket, lifetime) do
          :ok ->
            {:ok, %LockResponse{
              isError: false,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: "acquire_lock successfully."}
            }
          {:error, reason} ->
            {:ok, %LockResponse{
              isError: true,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: reason}
            }
        end
    end
  end

  # Only if the record is locked, then change the record lock time to the passed time, owner must match.
  def extend_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do

  end

  # Permanently locks a record if it is not locked.
  def persist_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do

  end

  # Get the record blocked or not.
  def poll_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do

  end

  # Get if the records are blocked.
  def poll_lock_list(%LockRequestList{owner: owner, tickets: tickets, lifetime: lifetime}, _stream) do

  end
end