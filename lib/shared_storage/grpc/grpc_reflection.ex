#defmodule SharedStorage.Reflection.Server do
#  @moduledoc """
#  A module for initialisation grpc Reflection.
#  """
#
#  use GrpcReflection.Server,
#      version: :v1alpha,
#      services: [LockService.LockService.Service]
#
#  def start_link(_) do
#    GRPC.Server.start(__MODULE__, 50051)
#  end
#
#  def child_spec(opts) do
#    %{
#      id: __MODULE__,
#      start: {__MODULE__, :start_link, [opts]},
#      type: :supervisor,
#      restart: :permanent,
#      shutdown: 500
#    }
#  end
#end