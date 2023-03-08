defmodule QuickAuction.Backend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:libcluster, :topologies)
    IO.inspect(topologies)

    children = [
      # Starts a worker by calling: QuickAuction.Backend.Worker.start_link(arg)
      # {QuickAuction.Backend.Worker, arg}
      {Cluster.Supervisor, [topologies, [name: QuickAuction.ClusterSupervisor]]},
      {Phoenix.PubSub, name: QuickAuction.PubSub},
      QuickAuction.Backend.Boundary.Products,
      QuickAuction.Backend.Boundary.Auctions
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuickAuction.Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
