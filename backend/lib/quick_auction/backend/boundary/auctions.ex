defmodule QuickAuction.Backend.Boundary.Auctions do
  use GenServer
  require Logger
  alias QuickAuction.Core.Auction
  alias QuickAuction.Backend.Boundary.Products

  def start_link(args) do
    Logger.debug("start_link")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def current do
    GenServer.call(__MODULE__, :get_current)
  end

  def all do
    GenServer.call(__MODULE__, :get_auctions)
  end

  @impl true
  def init(_args) do
    Logger.debug("init")
    {:ok, [], {:continue, :create_first_auction}}
  end

  @impl true
  def handle_continue(:create_first_auction, _state) do
    Logger.debug("handle_continue :create_first_auction")

    auction = new_auction()

    tick()
    {:noreply, %{auctions: [auction], current: auction}}
  end

  @impl true
  def handle_call(:get_current, _from, %{current: current} = state),
    do: {:reply, current, state}

  @impl true
  def handle_call(:get_auctions, _from, %{auctions: auctions} = state),
    do: {:reply, auctions, state}

  @impl true
  def handle_info(:tick, %{current: current, auctions: auctions} = state) do
    now = DateTime.utc_now()
    end_of_auction = current.end_time

    case DateTime.compare(now, end_of_auction) do
      result when result in [:gt, :eq] ->
        Logger.debug("Auction ended #{inspect(current)}")
        auction = new_auction()
        Logger.debug("New auction #{inspect(auction)}")

        tick()
        {:noreply, %{current: auction, auctions: [auction | auctions]}}

      :lt ->
        Logger.debug("Auction ongoing #{inspect(current)}")
        tick()
        {:noreply, state}
    end
  end

  defp tick do
    Process.send_after(__MODULE__, :tick, 1_000)
  end

  defp new_auction do
    {:ok, product} = Products.random()
    start_time = DateTime.utc_now()
    end_time = DateTime.add(start_time, 10, :second)
    {:ok, auction} = Auction.new(product, start_time, end_time)
    auction
  end
end
