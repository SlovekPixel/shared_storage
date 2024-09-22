defmodule SharedStorage.GRPCHandler do
  @moduledoc """
  A module for implementing handler logic.
  """

  alias LockService.{
    LockRequest,
    LockResponse,
    LockRequestNoTime,
    LockResponseNoTime,
    LockRequestList,
    LockResponseList,
    LockRequestNoTimeList,
    LockResponseNoTimeList,
    PollResponse,
    PollResponseList
    }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  # Lock the recording for a period of time if the recording is not locked.
  def acquire_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        case RedisClient.set_timeLock_notExists(owner, ticket, lifetime) do
          :ok ->
            {:ok, %LockResponse{
              isError: false,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: ResponseMessages.success_message("acquire_lock")}
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
      {:ok, true} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: ResponseMessages.ticket_already_blocked()}
        }
      {:error, _reason} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: _reason}
        }
    end
  end

  # Unlocks the record if the record is locked and owner matches.
  def release_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.verify_owner(owner, ticket) do
      {:ok, true} ->
        case RedisClient.release_lock(owner, ticket) do
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

      {:ok, false} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: "Owner mismatch. Cannot release_lock for ticket #{ticket}."
        }}

      {:error, _reason} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: _reason
        }}
    end
  end

  # Lock the record for a period of time, even if it is already locked. But if it is locked, it must match the owner.
  def ensure_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do

  end

  # Only if the record is locked, then change the record lock time to the passed time, owner must match.
  def extend_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do

  end

  # Permanently locks a record if it is not locked.
  def persist_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do

  end

  # Get the record blocked or not.
  def poll_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        {:ok, %PollResponse{
          isError: false,
          isBlocked: false,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          }}
        }
      {:ok, true} ->
        {:ok, %PollResponse{
          isError: false,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          }}
        }
      {:error, _reason} ->
        {:ok, %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          }}
        }
    end
  end

  # Get if the records are blocked.
  def poll_lock_list(%LockRequestList{owner: owner, tickets: tickets, lifetime: lifetime}, _stream) do

  end
end