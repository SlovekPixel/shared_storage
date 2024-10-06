defmodule SharedStorage.GRPCHandler.ReleaseLock do
  @moduledoc """
  A module for implementing release_lock logic.
  """

  alias SharedStorage.{
    LockRequestNoTime,
    LockResponseNoTime,
  }
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

  @method_name "release_lock"

  # Unlocks the record if the record is locked and owner matches.
  def release_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.verify_owner(owner, ticket) do
      {:ok, true} ->
        case RedisClient.release_lock(owner, ticket) do
          :ok ->
            %LockResponseNoTime{
              isError: false,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.success_message(@method_name)
            }

          {:error, :not_found} ->
            %LockResponseNoTime{
              isError: true,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.ticket_not_blocked()
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

      {:ok, false} ->
        %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: ResponseMessages.ticket_not_blocked()
        }

      {:error, reason} ->
        %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: reason
        }
    end
  end
end