defmodule SharedStorage.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_host = System.get_env("REDIS_HOST") |> String.trim();
    redis_port = System.get_env("REDIS_PORT") |> String.trim() |> String.to_integer();
    grpcPort = System.get_env("GRPC_PORT") |> String.trim() |> String.to_integer();

    children = [
      {DNSCluster, query: Application.get_env(:shared_storage, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SharedStorage.PubSub},
      {Redix, host: redis_host, port: redis_port, name: :redix},
      {GRPC.Server.Supervisor, endpoint: SharedStorage.Endpoint, port: grpcPort, start_server: true},
      GrpcReflection
    ]

    opts = [strategy: :one_for_one, name: SharedStorage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
