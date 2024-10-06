defmodule SharedStorage.GRPCHandler.PollLock do
  @moduledoc """
  A module for implementing poll_lock logic.
  """

  alias SharedStorage.{
    LockRequestNoTime,
    PollResponse,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  @method_name "poll_lock"

  # Get the record blocked or not.
  def poll_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        %PollResponse{
          isError: false,
          isBlocked: false,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: ResponseMessages.success_message(@method_name)
        }
      {:ok, true} ->
        %PollResponse{
          isError: false,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: ResponseMessages.success_message(@method_name)
        }
      {:error, reason} ->
        %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: reason
        }
    end
  end
end