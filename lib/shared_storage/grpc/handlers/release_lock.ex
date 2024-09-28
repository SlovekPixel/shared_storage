defmodule SharedStorage.GRPCHandler.ReleaseLock do
  @moduledoc """
  A module for implementing release_lock logic.
  """

  alias SharedStorage.{
    LockRequestNoTime,
    LockResponseNoTime}
  alias SharedStorage.Redis.RedisClient
  alias SharedStorage.Messages.ResponseMessages

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
              message: ResponseMessages.success_message("release_lock")
            }}

          {:error, :not_found} ->
            {:ok, %LockResponseNoTime{
              isError: true,
              lock: %LockRequestNoTime{
                owner: owner,
                ticket: ticket
              },
              message: ResponseMessages.ticket_not_blocked()
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
          message: ResponseMessages.ticket_not_blocked()
        }}

      {:error, reason} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          },
          message: reason
        }}
    end
  end
end