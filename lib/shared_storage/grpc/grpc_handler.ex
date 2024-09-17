defmodule SharedStorage.GRPCHandler do
  alias LockService.{LockRequest, LockResponse, LockRequestNoTime, LockResponseNoTime}
  alias SharedStorage.Redis.RedisClient

  def acquire_lock(%LockRequest{owner: owner, ticket: ticket, lifetime: lifetime}, _stream) do
    case RedisClient.set_timeLock(owner, ticket, lifetime) do
      :ok ->
        {:ok, %LockResponse{
          isError: false,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: "acquire_lock successfully."}
        }
      {:error, reason} ->
        {:ok, %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: owner,
            ticket: ticket,
            lifetime: lifetime
          },
          message: reason}
        }
    end
  end

  def release_lock(%LockRequestNoTime{owner: owner, ticket: ticket}, _stream) do
    case RedisClient.release_lock(ticket, owner) do
      :ok ->
        {:ok, %LockResponseNoTime{
          isError: false,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: "Lock released successfully."
        }}

      {:error, :not_found} ->
        {:ok, %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: owner,
            ticket: ticket
          },
          message: "Lock not found."
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
  end
end