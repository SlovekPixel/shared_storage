defmodule SharedStorage.GRPCHandler.AcquireLock do
  @moduledoc """
  A module for implementing acquire_lock logic.
  """

  alias SharedStorage.{
    LockRequest,
    LockResponse,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  @method_name "acquire_lock"

  def acquire_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        case RedisClient.set_timeLock_notExists(owner, ticket, lifetime) do
          :ok ->
            %LockResponse{
              isError: false,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: ResponseMessages.success_message(@method_name)
            }
          {:error, reason} ->
            %LockResponse{
              isError: true,
              lock: %LockRequest{
                owner: owner,
                ticket: ticket,
                lifetime: lifetime
              },
              message: reason
            }
        end
      {:ok, true} ->
        %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: ResponseMessages.ticket_already_blocked()
        }
      {:error, reason} ->
        %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: reason
        }
    end
  end
end