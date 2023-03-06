defmodule QuickAuction.Backend.Boundary.Auctions do
  use GenServer
  require Logger
  alias QuickAuction.Core.Auction
  alias QuickAuction.Backend.Boundary.Products

  def start_link(args) do
    Logger.debug("start_link")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.debug("init")
    {:ok, [], {:continue, :create_first_auction}}
  end

  @impl true
  def handle_continue(:create_first_auction, _state) do
    product = Products.random()
    auction = Auction.new(product, DateTime.utc_now())
    {:noreply, %{auctions: [], current: auction}}
  end
end
