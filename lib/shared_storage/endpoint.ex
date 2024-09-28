defmodule SharedStorage.Endpoint do
  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)
  run(SharedStorage.LockService.Server)
  run(SharedStorage.Reflection.Server)
end