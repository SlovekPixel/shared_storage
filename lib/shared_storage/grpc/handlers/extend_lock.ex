defmodule SharedStorage.GRPCHandler.ExtendLock do
  @moduledoc """
  A module for implementing extend_lock logic.
  """

  alias SharedStorage.{
    LockRequest,
    LockResponse}
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  # Only if the record is locked, then change the record lock time to the passed time, owner must match.
  def extend_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
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
                  message: ResponseMessages.success_message("extend_lock")
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
      {:ok, false} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: ResponseMessages.ticket_not_blocked()
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
  end
end