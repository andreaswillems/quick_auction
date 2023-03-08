defmodule QuickAuction.Backend.Boundary.Auctions do
  use GenServer
  require Logger
  alias QuickAuction.Core.{Auction, Bid}
  alias QuickAuction.Backend.Boundary.Products

  def start_link(args) do
    Logger.debug("start_link")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def current do
    Logger.debug("current")
    GenServer.call(__MODULE__, :get_current)
  end

  def all do
    Logger.debug("all")
    GenServer.call(__MODULE__, :get_auctions)
  end

  def put_bid(%Bid{} = bid) do
    Logger.debug("put bid")
    GenServer.call(__MODULE__, {:put_bid, bid})
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
    Logger.debug("handle_continue :create_first_auction auction #{inspect(auction)}")

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
  def handle_call({:put_bid, bid}, _from, %{current: current, auctions: auctions} = _state) do
    Logger.debug("handle_call :put_bid")

    updated_current = Auction.add_bid(current, bid)
    [_ | tail] = auctions
    updated_auctions = [updated_current | tail]
    IO.inspect(updated_auctions)

    {:reply, updated_current, %{current: updated_current, auctions: updated_auctions}}
  end

  @impl true
  def handle_info(:tick, %{current: current, auctions: auctions} = state) do
    IO.inspect(state)
    now = DateTime.utc_now()
    end_of_auction = current.end_time

    case DateTime.compare(now, end_of_auction) do
      result when result in [:gt, :eq] ->
        auction = new_auction()
        Logger.debug("New auction #{inspect(auction)}")

        tick()
        {:noreply, %{current: auction, auctions: [auction | auctions]}}

      :lt ->
        Logger.debug("Current auction #{inspect(current)}")
        tick()
        {:noreply, state}
    end
  end

  defp tick do
    Process.send_after(__MODULE__, :tick, 30_000)
  end

  defp new_auction do
    [unit: unit, amount: amount_to_add] = Application.fetch_env!(:backend, :auctions)
    product = Products.random()
    IO.inspect(product)

    start_time = DateTime.utc_now()
    IO.inspect(start_time)

    end_time = DateTime.add(start_time, amount_to_add, unit)
    IO.inspect(end_time)

    {:ok, auction} = Auction.new(product, start_time, end_time)
    auction
  end
end
