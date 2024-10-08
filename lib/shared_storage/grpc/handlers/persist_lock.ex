defmodule SharedStorage.GRPCHandler.PersistLock do
  @moduledoc """
  A module for implementing persist_lock logic.
  """

  alias SharedStorage.{
    LockRequestNoTime,
    LockResponseNoTime,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  @method_name "persist_lock"

  #Permanently locks a record if it is not locked.
  def persist_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.is_ticket_locked(ticket) do
      {:ok, false} ->
        case RedisClient.set_noTimeLock_force(owner, ticket) do
          :ok ->
            %LockResponseNoTime{
              isError: false,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.success_message(@method_name)
            }
          {:error, reason} ->
            %LockResponseNoTime{
              isError: true,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: reason
            }
        end
      {:ok, true} ->
        %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: ResponseMessages.ticket_already_blocked()
        }
      {:error, reason} ->
        %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: reason
        }
    end
  end
end