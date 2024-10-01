defmodule SharedStorage.GRPCHandler.EnsureLock do
  @moduledoc """
  A module for implementing ensure_lock logic.
  """

  alias SharedStorage.{
    LockRequest,
    LockResponse,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  # Lock the record for a period of time, even if it is already locked. But if it is locked, it must match the owner.
  def ensure_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        case RedisClient.set_timeLock_force(owner, ticket, lifetime) do
          :ok ->
            {:ok, %LockResponse{
              isError: false,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: ResponseMessages.success_message("ensure_lock")
            }}
          {:error, reason} ->
            {:ok, %LockResponse{
              isError: true,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: reason
            }}
        end

      {:ok, true} ->
        case RedisClient.verify_owner(owner, ticket) do
          {:ok, true} ->
            case RedisClient.set_timeLock_force(owner, ticket, lifetime) do
              :ok ->
                {:ok, %LockResponse{
                  isError: false,
                  lock: %LockRequest{
                    owner: owner,
                    ticket: ticket,
                    lifetime: lifetime
                  },
                  message: ResponseMessages.success_message("ensure_lock")
                }}
              {:error, reason} ->
                {:ok, %LockResponse{
                  isError: true,
                  lock: %LockRequest{
                    owner: owner,
                    ticket: ticket,
                    lifetime: lifetime
                  },
                  message: reason
                }}
            end

          {:ok, false} ->
            {:ok, %LockResponse{
              isError: true,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: ResponseMessages.owner_mismatch()
            }}

          {:error, reason} ->
            {:ok, %LockResponse{
              isError: true,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: reason
            }}
        end
      {:error, reason} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: reason
        }}
    end
  end
end