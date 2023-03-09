defmodule QuickAuction.Backend.Boundary.Adapter do
  use GenServer
  require Logger
  alias QuickAuction.Core.Auction
  alias QuickAuction.Backend.Boundary.Auctions

  @pubsub_name Application.compile_env!(:backend, :pubsub_name)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def notify_auction_updated(%Auction{} = auction) do
    GenServer.cast(__MODULE__, {:notify_auction_updated, auction})
  end

  @impl true
  def init(_args) do
    {:ok, [], {:continue, :register_subscribers}}
  end

  @impl true
  def handle_continue(:register_subscribers, state) do
    Phoenix.PubSub.subscribe(@pubsub_name, "auction_requested")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:notify_auction_udpated, auction}, state) do
    Phoenix.PubSub.broadcast(@pubsub_name, "auction_updated", {:auction_updated, auction})
    {:noreply, state}
  end

  @impl true
  def handle_info(:auction_requested, state) do
    auction = Auctions.current()
    Phoenix.PubSub.broadcast(@pubsub_name, "auction_updated", {:auction_updated, auction})
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug("Unknown message #{inspect(msg)}")
    {:noreply, state}
  end
end
