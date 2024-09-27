defmodule SharedStorage.GRPCHandler.PollLock do
  @moduledoc """
  A module for implementing poll_lock logic.
  """

  alias LockService.{
    LockRequestNoTime,
    PollResponse}
  alias SharedStorage.Redis.RedisClient

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
          }
        }}
      {:ok, true} ->
        {:ok, %PollResponse{
          isError: false,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          }
        }}
      {:error, _reason} ->
        {:ok, %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket,
          }
        }}
    end
  end
end