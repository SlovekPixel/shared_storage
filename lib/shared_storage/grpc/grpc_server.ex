defmodule SharedStorage.LockService.Server do
  @moduledoc """
  Description of gRPC controllers and reflection server.
  """

  use GRPC.Server, service: SharedStorage.LockService.Service

  @spec acquire_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
    LockService.LockResponse.t()
  def acquire_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.AcquireLock.acquire_lock(request, stream)
    response
  end

  @spec release_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponseNoTime.t()
  def release_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.ReleaseLock.release_lock(request, stream)
    response
  end

  @spec ensure_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponse.t()
  def ensure_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.EnsureLock.ensure_lock(request, stream)
    response
  end

  @spec extend_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponse.t()
  def extend_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.ExtendLock.extend_lock(request, stream)
    response
  end

  @spec persist_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponseNoTime.t()
  def persist_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PersistLock.persist_lock(request, stream)
    response
  end

  @spec poll_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.PollResponse.t()
  def poll_lock(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PollLock.poll_lock(request, stream)
    response
  end

  @spec acquire_lock(LockService.LockRequestNoTimeList.t(), GRPC.Server.Stream.t()) ::
          LockService.PollResponseList.t()
  def poll_lock_list(request, stream) do
    { status, response } = SharedStorage.GRPCHandler.PollLockList.poll_lock_list(request, stream)
    response
  end
end