defmodule SharedStorage.GRPCServer do
  @moduledoc """
  Description of grpc controllers.
  """

  use GRPC.Server,
      service: LockService.LockService.Service

  def start_link(_) do
    GRPC.Server.start(__MODULE__, 50051)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def acquire_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.acquire_lock(request, stream)
    response
  end

  def release_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.release_lock(request, stream)
    response
  end

  def ensure_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.ensure_lock(request, stream)
    response
  end

  def extend_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.extend_lock(request, stream)
    response
  end

  def persist_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.persist_lock(request, stream)
    response
  end

  def poll_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.poll_lock(request, stream)
    response
  end

  def poll_lock_list(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.poll_lock_list(request, stream)
    response
  end
end