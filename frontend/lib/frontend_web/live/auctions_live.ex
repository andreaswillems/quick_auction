defmodule QuickAuction.FrontendWeb.AuctionsLive do
  use QuickAuction.FrontendWeb, :live_view
  require Logger

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
       end_time: "",
       current_price: 100,
       product: %{name: "", description: "", image_url: ""}
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
    <div class="p-16">
      <!--Card 1-->
      <div class="mix-w-sm max-w-md rounded overflow-hidden shadow-xl">
        <img class="mx-auto max-h-96" src={@auction.product.image_url} alt="Mountain" />
        <div class="px-6 py-4">
          <div class="font-bold text-xl mb-2"><%= @auction.product.name %></div>
          <p class="text-gray-700 text-base">
            <%= @auction.product.description %>
          </p>
        </div>
        <hr />
        <div class="px-6 pt-4 pb-2 w-full">
          <div class="flex flex-row text-l mb-2">
            <div class="font-bold">Auction ends at</div>
            <div class="flex-grow text-right"><%= @auction.end_time %></div>
          </div>
          <div class="flex flex-row text-l mb-2">
            <div class="font-bold">Current price</div>
            <div class="flex-grow text-right"><%= @auction.current_price %> €</div>
          </div>
          <div class="flex flex-row text-l mb-2">
            <div class="font-bold">Highest bidder:</div>
            <div class="flex-grow text-right">Andreas</div>
          </div>
        </div>
        <hr />
        <div>
          <div class="w-full p-4">
            <h3 class="text-center text-xl text-gray-700 mb-2 font-bold">Make Bid</h3>
            <%= if @loading do %>
              <div class="border border-purple-800 rounded-lg px-4 py-3 mx-0 shadow-outline">
                <svg
                  class={["animate-spin h-5 w-5 mx-auto"]}
                  width="100"
                  height="100"
                  viewBox="0 0 22 22"
                  xmlns="http://www.w3.org/2000/svg"
                  stroke="#6b21a8"
                >
                  <g fill="none" fill-rule="evenodd" stroke-width="2">
                    <circle cx="11" cy="11" r="1">
                      <animate
                        attributeName="r"
                        begin="0s"
                        dur="1.8s"
                        values="1; 10"
                        calcMode="spline"
                        keyTimes="0; 1"
                        keySplines="0.165, 0.84, 0.44, 1"
                        repeatCount="indefinite"
                      />
                      <animate
                        attributeName="stroke-opacity"
                        begin="0s"
                        dur="1.8s"
                        values="1; 0"
                        calcMode="spline"
                        keyTimes="0; 1"
                        keySplines="0.3, 0.61, 0.355, 1"
                        repeatCount="indefinite"
                      />
                    </circle>
                    <circle cx="11" cy="11" r="1">
                      <animate
                        attributeName="r"
                        begin="-0.9s"
                        dur="1.8s"
                        values="1; 10"
                        calcMode="spline"
                        keyTimes="0; 1"
                        keySplines="0.165, 0.84, 0.44, 1"
                        repeatCount="indefinite"
                      />
                      <animate
                        attributeName="stroke-opacity"
                        begin="-0.9s"
                        dur="1.8s"
                        values="1; 0"
                        calcMode="spline"
                        keyTimes="0; 1"
                        keySplines="0.3, 0.61, 0.355, 1"
                        repeatCount="indefinite"
                      />
                    </circle>
                  </g>
                </svg>
              </div>
            <% end %>
            <%= unless @loading do %>
              <div class="flex gap-1 justify-around rounded-lg text-lg" role="group">
                <button
                  phx-click="make_bid"
                  phx-value-amount="1"
                  phx-throttle="5000"
                  class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline"
                >
                  <span>0,01 €</span>
                </button>
                <button
                  phx-click="make_bid"
                  phx-value-amount="10"
                  phx-throttle="5000"
                  class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline"
                >
                  0,10 €
                </button>
                <button
                  phx-click="make_bid"
                  phx-value-amount="100"
                  phx-throttle="5000"
                  class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline"
                >
                  1,00 €
                </button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:auction_updated, auction}, socket) do
    Logger.debug("handle_info :auction_updated #{inspect(auction)}")
    {:noreply, assign(socket, auction: format_auction(auction))}
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

  defp format_auction(auction) do
    updated_end_time = format_end_time(auction.end_time)
    updated_price = format_price(auction.current_price)

    %{auction | end_time: updated_end_time, current_price: updated_price}
  end

  defp format_end_time(timestamp) do
    timestamp
    |> DateTime.shift_zone!("Europe/Berlin")
    |> DateTime.to_time()
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end

  defp format_price(price) when is_integer(price) do
    (price / 100) |> :erlang.float_to_binary(decimals: 2)
  end
end
