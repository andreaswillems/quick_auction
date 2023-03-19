defmodule QuickAuction.Backend.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: QuickAuction.ClusterSupervisor]]},
      {Phoenix.PubSub, name: QuickAuction.PubSub},
      QuickAuction.Backend.Boundary.Products,
      QuickAuction.Backend.Boundary.Auctions,
      QuickAuction.Backend.Boundary.Adapter
    ]

    opts = [strategy: :one_for_one, name: QuickAuction.Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
