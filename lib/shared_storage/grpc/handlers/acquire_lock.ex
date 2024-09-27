defmodule SharedStorage.GRPCHandler.AcquireLock do
  @moduledoc """
  A module for implementing acquire_lock logic.
  """

  alias LockService.{
    LockRequest,
    LockResponse}
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

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
              message: ResponseMessages.success_message("acquire_lock")
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
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: ResponseMessages.ticket_already_blocked()
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