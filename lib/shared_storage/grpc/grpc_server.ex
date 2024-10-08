defmodule SharedStorage.LockService.Server do
  @moduledoc """
  Description of gRPC controllers and reflection server.
  """

  use GRPC.Server, service: SharedStorage.LockService.Service
#  use LoggingDecorator
  alias SharedStorage.Validators.LockValidator

#  @decorate log()
  @spec acquire_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
    LockService.LockResponse.t()
  def acquire_lock(request, stream) do
    case LockValidator.validate_lock_request(request) do
      :ok -> SharedStorage.GRPCHandler.AcquireLock.acquire_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec release_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponseNoTime.t()
  def release_lock(request, stream) do
    case LockValidator.validate_lock_request_no_time(request) do
      :ok -> SharedStorage.GRPCHandler.ReleaseLock.release_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec ensure_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponse.t()
  def ensure_lock(request, stream) do
    case LockValidator.validate_lock_request(request) do
      :ok -> SharedStorage.GRPCHandler.EnsureLock.ensure_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec extend_lock(LockService.LockRequest.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponse.t()
  def extend_lock(request, stream) do
    case LockValidator.validate_lock_request(request) do
      :ok -> SharedStorage.GRPCHandler.ExtendLock.extend_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec persist_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.LockResponseNoTime.t()
  def persist_lock(request, stream) do
    case LockValidator.validate_lock_request_no_time(request) do
      :ok -> SharedStorage.GRPCHandler.PersistLock.persist_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec poll_lock(LockService.LockRequestNoTime.t(), GRPC.Server.Stream.t()) ::
          LockService.PollResponse.t()
  def poll_lock(request, stream) do
    case LockValidator.validate_poll_request(request) do
      :ok -> SharedStorage.GRPCHandler.PollLock.poll_lock(request, stream)
      {:error, response} -> response
    end
  end

  @spec poll_lock_list(LockService.LockRequestNoTimeList.t(), GRPC.Server.Stream.t()) ::
          LockService.PollResponseList.t()
  def poll_lock_list(request, stream) do
    case LockValidator.validate_lock_request_no_time_list(request) do
      :ok -> SharedStorage.GRPCHandler.PollLockList.poll_lock_list(request, stream)
      {:error, response} -> response
    end
  end
end