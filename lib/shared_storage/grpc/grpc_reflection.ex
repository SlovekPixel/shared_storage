defmodule SharedStorage.Reflection.Server do
  @moduledoc """
  A module for initialisation grpc Reflection.
  """

  use GrpcReflection.Server,
      version: :v1alpha,
      services: [SharedStorage.LockService.Service]
end