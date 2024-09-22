defmodule SharedStorage.Reflection.Server do
  @moduledoc """
  A module for initialisation grpc Reflection.
  """

  use GrpcReflection.Server,
      version: :v1,
      services: [SharedStorage.LockService.LockService.Service]

  def start_link(opts) do
    GrpcReflection.Server.start_link(opts)
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
end