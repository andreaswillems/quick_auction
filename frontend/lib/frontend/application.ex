defmodule QuickAuction.Frontend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:libcluster, :topologies)

    children = [
      # Start cluster supervisor
      {Cluster.Supervisor, [topologies, [name: QuickAuction.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      QuickAuction.FrontendWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: QuickAuction.PubSub},
      # Start the Endpoint (http/https)
      QuickAuction.FrontendWeb.Endpoint,
      QuickAuction.FrontendWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuickAuction.Frontend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuickAuction.FrontendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
