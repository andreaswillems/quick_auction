defmodule QuickAuction.FrontendWeb.AuctionsLive do
  use QuickAuction.FrontendWeb, :live_view
  require Logger
  alias QuickAuction.FrontendWeb.Components.{Auction, Bid, Product}

  @pubsub_name Application.compile_env!(:frontend, QuickAuction.FrontendWeb.Endpoint)[
                 :pubsub_server
               ]

  @impl true
  def mount(_params, session, socket) do
    user_name = session["user_name"]
    user_id = session["user_id"]

    if connected?(socket) do
      Phoenix.PubSub.subscribe(@pubsub_name, "auction_updated")
      Phoenix.PubSub.broadcast(@pubsub_name, "auction_requested", :auction_requested)
    end

    {:ok,
     socket
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
     |> assign(:loading_1, false)
     |> assign(:loading_10, false)
     |> assign(:loading_100, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Hello <%= @user_name %></h1>
    <div class="mx-auto w-2/3 bg-white p-4 rounded overflow-hidden shadow-xl">
      <div class="grid grid-cols-3">
        <div class="col-span-2 border-r-solid border-r-2">
          <Product.info product={@auction.product} />
        </div>
        <div>
          <Auction.info
            start_time={@auction.start_time}
            end_time={@auction.end_time}
            current_price={@auction.current_price}
            current_winner={@auction.current_winner}
          />

          <div>
            <div class="w-full p-4">
              <h3 class="text-center text-xl text-gray-700 mb-2 font-bold">Make Bid</h3>
              <Auction.activity_indicator :if={@loading} />

              <div
                :if={!@loading}
                class="flex flex-col gap-1 justify-around rounded-lg text-lg"
                role="group"
              >
                <Auction.bid_button title="0.01" event_name="make_bid" event_value="1" />
                <Auction.bid_button title="0.10" event_name="make_bid" event_value="10" />
                <Auction.bid_button title="1.00" event_name="make_bid" event_value="100" />
              </div>
            </div>
          </div>
        </div>
      </div>
      <hr />
      <Bid.list bids={@auction.bids} />
    </div>
    """
  end

  @impl true
  def handle_info({:auction_updated, auction}, socket) do
    Logger.debug("handle_info :auction_updated #{inspect(auction)}")
    {:noreply, assign(socket, auction: auction)}
  end

  @impl true
  def handle_info(:clear_animation, socket) do
    {:noreply, assign(socket, :loading, false)}
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
end
