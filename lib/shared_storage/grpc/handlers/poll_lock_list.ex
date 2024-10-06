defmodule SharedStorage.GRPCHandler.PollLockList do
  @moduledoc """
  A module for implementing poll_lock_list logic.
  """

  alias SharedStorage.{
    LockRequestNoTimeList,
    LockRequestNoTime,
    PollResponse,
    PollResponseList,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  @method_name "poll_lock_list"

  # Get the record blocked or not.
  def poll_lock_list(%LockRequestNoTimeList{owner: owner, tickets: tickets}, _stream) do
    # Process each ticket individually
    responses =
      Enum.map(tickets, fn ticket ->
        case RedisClient.is_ticket_locked(ticket) do
          {:ok, false} ->
            %PollResponse{
              isError: false,
              isBlocked: false,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.success_message(@method_name)
            }
          {:ok, true} ->
            %PollResponse{
              isError: false,
              isBlocked: true,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.success_message(@method_name)
            }
          {:error, reason} ->
            %PollResponse{
              isError: true,
              isBlocked: true,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: reason
            }
        end
      end)

    overall_is_blocked = Enum.any?(responses, fn resp -> resp.isBlocked end)
    overall_is_error = Enum.any?(responses, fn resp -> resp.isError end)

    %PollResponseList{
      isBlocked: overall_is_blocked,
      isError: overall_is_error,
      responses: responses,
      message: ResponseMessages.success_message(@method_name),
    }
  end
end