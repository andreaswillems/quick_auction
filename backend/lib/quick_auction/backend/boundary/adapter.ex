defmodule QuickAuction.Backend.Boundary.Adapter do
  use GenServer
  require Logger
  alias QuickAuction.Core.{Auction, Bid, User}
  alias QuickAuction.Backend.Boundary.Auctions

  @pubsub_name Application.compile_env!(:backend, :pubsub_name)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def notify_auction_updated(%Auction{} = auction) do
    Logger.debug("notify_auction_updated #{inspect(auction)}")
    GenServer.cast(__MODULE__, {:notify_auction_updated, auction})
  end

  def notify_auction_ended(%Auction{} = auction) do
    Logger.debug("notify_auction_ended #{inspect(auction)}")
    GenServer.cast(__MODULE__, {:notify_auction_ended, auction})
  end

  @impl true
  def init(_args) do
    {:ok, [], {:continue, :register_subscribers}}
  end

  @impl true
  def handle_continue(:register_subscribers, state) do
    Logger.debug("handle_continue :register_subscribers")
    Phoenix.PubSub.subscribe(@pubsub_name, "auction_requested")
    Phoenix.PubSub.subscribe(@pubsub_name, "make_bid")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:notify_auction_updated, auction}, state) do
    Logger.debug("handle_cast :notify_auction_updated")
    Phoenix.PubSub.broadcast(@pubsub_name, "auction_updated", {:auction_updated, auction})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:notify_auction_ended, auction}, state) do
    Logger.debug("handle_cast :notify_auction_ended")
    Phoenix.PubSub.broadcast(@pubsub_name, "auction_ended", {:auction_ended, auction})
    {:noreply, state}
  end

  @impl true
  def handle_info(:auction_requested, state) do
    Logger.debug("handle_info :auction_requested")
    auction = Auctions.current()
    Phoenix.PubSub.broadcast(@pubsub_name, "auction_updated", {:auction_updated, auction})
    {:noreply, state}
  end

  @impl true
  def handle_info({:make_bid, %{user_id: user_id, user_name: user_name, amount: amount}}, state) do
    Logger.debug("handle_info :make_bid")
    user = %User{name: user_name, id: user_id}
    {:ok, bid} = Bid.new(user, amount, DateTime.utc_now())
    Auctions.put_bid(bid)

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug("Unknown message #{inspect(msg)}")
    {:noreply, state}
  end
end
