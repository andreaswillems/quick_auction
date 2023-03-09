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
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Hello <%= @user_name %></h1>
    <div class="p-10">
      <!--Card 1-->
      <div class="mix-w-sm max-w-md rounded overflow-hidden shadow-lg">
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
          <div class="w-full">
            <h3 class="text-center text-xl text-gray-700 mb-2 font-bold">Make Bid</h3>
            <div class="flex gap-1 justify-around rounded-lg text-lg" role="group">
              <button class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline">
                0,01 €
              </button>
              <button class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline">
                0,10 €
              </button>
              <button class="bg-white flex-grow text-purple-800 hover:bg-purple-800 hover:text-white border border-purple-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline">
                1,00 €
              </button>
            </div>
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

  # fallback handler
  @impl true
  def handle_info(msg, socket) do
    Logger.debug("handle_info unknown message #{inspect(msg)}")
    {:noreply, socket}
  end

  defp format_auction(auction) do
    updated_end_time = auction.end_time |> format_end_time()

    %{auction | end_time: updated_end_time}
  end

  defp format_end_time(timestamp) do
    timestamp
    |> DateTime.shift_zone!("Europe/Berlin")
    |> DateTime.to_time()
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end
end
