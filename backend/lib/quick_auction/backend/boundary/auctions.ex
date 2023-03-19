defmodule QuickAuction.Backend.Boundary.Auctions do
  use GenServer
  require Logger
  alias QuickAuction.Core.{Auction, Bid}
  alias QuickAuction.Backend.Boundary.{Adapter, Products}

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def current, do: GenServer.call(__MODULE__, :get_current)

  def all, do: GenServer.call(__MODULE__, :get_auctions)

  def put_bid(%Bid{} = bid), do: GenServer.call(__MODULE__, {:put_bid, bid})

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
  def handle_call({:put_bid, bid}, _from, %{current: current, auctions: auctions} = _state) do
    Logger.debug("handle_call :put_bid")

    updated_current = Auction.add_bid(current, bid)

    [_ | tail] = auctions
    updated_auctions = [updated_current | tail]

    Adapter.notify_auction_updated(updated_current)

    {:reply, updated_current, %{current: updated_current, auctions: updated_auctions}}
  end

  @impl true
  def handle_info(:tick, %{current: current} = state) do
    now = DateTime.utc_now()
    end_of_auction = current.end_time

    case DateTime.compare(now, end_of_auction) do
      result when result in [:gt, :eq] ->
        Adapter.notify_auction_ended(current)
        Process.send_after(self(), :create_new_auction, 10_000)
        {:noreply, state}

      :lt ->
        tick()
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:create_new_auction, %{auctions: auctions}) do
    auction = new_auction()
    Adapter.notify_auction_updated(auction)

    tick()
    {:noreply, %{current: auction, auctions: [auction | auctions]}}
  end

  defp tick do
    Process.send_after(__MODULE__, :tick, 1_000)
  end

  defp new_auction do
    [unit: unit, amount: amount_to_add] = Application.fetch_env!(:backend, :auctions)
    product = Products.random()

    now = DateTime.utc_now() |> DateTime.truncate(:second)
    # shift starting time to next full minute
    start_time = now |> DateTime.add(-now.second, :second) |> DateTime.add(1, :minute)
    end_time = DateTime.add(start_time, amount_to_add, unit)

    {:ok, auction} = Auction.new(product, now, end_time)
    auction
  end
end
