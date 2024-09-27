defmodule SharedStorage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SharedStorageWeb.Telemetry,
      SharedStorage.Repo,
      {DNSCluster, query: Application.get_env(:shared_storage, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SharedStorage.PubSub},
      {Redix, host: "127.0.0.1", port: 6379, name: :redix},
      # Start a worker by calling: SharedStorage.Worker.start_link(arg)
      # {SharedStorage.Worker, arg},
      # Start to serve requests, typically the last entry
      SharedStorageWeb.Endpoint,
      SharedStorage.GRPCServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SharedStorage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SharedStorageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
