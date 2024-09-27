defmodule SharedStorage.GRPCServer do
  @moduledoc """
  Description of gRPC controllers and reflection server.
  """

  use GRPC.Server,
      service: LockService.LockService.Service

  use GrpcReflection.Server,
      version: :v1alpha,
      services: [LockService.LockService.Service]

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
    { status, response } = SharedStorage.GRPCHandler.AcquireLock.acquire_lock(request, stream)
    response
  end

  def release_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.ReleaseLock.release_lock(request, stream)
    response
  end

  def ensure_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.EnsureLock.ensure_lock(request, stream)
    response
  end

  def extend_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.ExtendLock.extend_lock(request, stream)
    response
  end

  def persist_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PersistLock.persist_lock(request, stream)
    response
  end

  def poll_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PollLock.poll_lock(request, stream)
    response
  end

  def poll_lock_list(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PollLockList.poll_lock_list(request, stream)
    response
  end
end