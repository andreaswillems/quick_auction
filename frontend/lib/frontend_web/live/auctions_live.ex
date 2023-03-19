defmodule QuickAuction.FrontendWeb.AuctionsLive do
  use QuickAuction.FrontendWeb, :live_view
  require Logger
  alias Phoenix.PubSub
  alias QuickAuction.FrontendWeb.Components.{Auction, Bid, Product, User}
  alias QuickAuction.FrontendWeb.Presence

  @pubsub_name QuickAuction.PubSub
  @auction_requested "auction_requested"
  @auction_updated "auction_updated"
  @auction_ended "auction_ended"
  @presence "auctions_presence"

  @impl true
  def mount(_params, session, socket) do
    user_name = session["user_name"]
    user_id = session["user_id"]

    if connected?(socket) do
      Presence.track(self(), @presence, user_id, %{
        name: user_name,
        joined_at: :os.system_time(:seconds)
      })

      PubSub.subscribe(@pubsub_name, @auction_updated)
      PubSub.subscribe(@pubsub_name, @auction_ended)
      PubSub.subscribe(@pubsub_name, @presence)

      PubSub.broadcast(@pubsub_name, @auction_requested, :auction_requested)
    end

    {:ok,
     socket
     |> assign(:logged_in, true)
     |> assign(:user_name, user_name)
     |> assign(:user_id, user_id)
     |> assign(:auction, %{
       start_time: DateTime.utc_now(),
       end_time: DateTime.utc_now(),
       current_price: 0,
       current_winner: %{name: ""},
       product: %{name: "", description: "", image_url: ""},
       bids: []
     })
     |> assign(:loading, false)
     |> assign(:time_remaining, Time.utc_now())
     |> assign(:auction_ended, false)
     |> assign(:users, %{})
     |> handle_joins(Presence.list(@presence))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-2">
      <div class="lg:col-span-2">
        <!--Auction Card-->
        <div class="bg-white mix-w-sm max-w-md rounded overflow-hidden shadow-xl">
          <Product.info product={@auction.product} />
          <hr />
          <Auction.info
            start_time={@auction.start_time}
            end_time={@auction.end_time}
            remaining_time={@time_remaining}
            current_price={@auction.current_price}
            current_winner={@auction.current_winner}
          />
          <hr />
          <div>
            <div class="w-full p-4">
              <h2 :if={@auction_ended} class="text-center text-xl text-red-700 mb-2 font-bold">
                Auction ended
              </h2>
              <div :if={!@auction_ended}>
                <h3 class="text-center text-xl text-gray-700 mb-2 font-bold">Make Bid</h3>
                <Auction.activity_indicator :if={@loading} />

                <div :if={!@loading} class="flex gap-1 justify-around rounded-lg text-lg" role="group">
                  <Auction.bid_button title="0.01" event_name="make_bid" event_value="1" />
                  <Auction.bid_button title="0.10" event_name="make_bid" event_value="10" />
                  <Auction.bid_button title="1.00" event_name="make_bid" event_value="100" />
                </div>
              </div>
            </div>
          </div>
          <hr />
          <Bid.list :if={!@auction_ended} bids={@auction.bids} />
          <Bid.winner :if={@auction_ended} user={@auction.current_winner} />
        </div>
      </div>
      <!-- User area -->
      <div class="flex flex-col w-full">
        <div class="md:p-4 bg-white rounded overflow-hidden shadow-xl">
          <User.list user_id={@user_id} users={@users} />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:auction_updated, auction}, socket) do
    Logger.debug("handle_info :auction_updated")

    remaining_time = remaining_time(auction.end_time)

    tick()

    {:noreply,
     socket
     |> assign(:auction, auction)
     |> assign(:remaining_time, remaining_time)
     |> assign(:auction_ended, false)}
  end

  @impl true
  def handle_info({:auction_ended, _auction}, socket) do
    Logger.debug("handle_info :auction_ended")
    {:noreply, assign(socket, :auction_ended, true)}
  end

  @impl true
  def handle_info(:clear_animation, socket) do
    {:noreply, assign(socket, :loading, false)}
  end

  @impl true
  def handle_info(:tick, socket) do
    time_remaining = remaining_time(socket.assigns.auction.end_time)
    {seconds, _} = Time.to_seconds_after_midnight(time_remaining)

    if seconds > 0 do
      tick()
    end

    {:noreply, assign(socket, time_remaining: time_remaining)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply,
     socket
     |> handle_leaves(diff.leaves)
     |> handle_joins(diff.joins)}
  end

  # fallback handler
  @impl true
  def handle_info(msg, socket) do
    Logger.debug("handle_info unknown message #{inspect(msg)}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("make_bid", %{"amount" => amount_raw}, socket) do
    Logger.debug("handle_event make_bid #{inspect(amount_raw)}")
    {amount, _} = Integer.parse(amount_raw)

    Phoenix.PubSub.broadcast(
      @pubsub_name,
      "make_bid",
      {:make_bid,
       %{user_id: socket.assigns.user_id, user_name: socket.assigns.user_name, amount: amount}}
    )

    Process.send_after(self(), :clear_animation, 5_000)
    {:noreply, assign(socket, :loading, true)}
  end

  defp tick, do: Process.send_after(self(), :tick, 1_000)

  defp remaining_time(end_time),
    do:
      end_time
      |> DateTime.to_time()
      |> Time.diff(Time.utc_now())
      |> Time.from_seconds_after_midnight()

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end
end
