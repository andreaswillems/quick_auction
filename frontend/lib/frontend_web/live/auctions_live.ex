defmodule QuickAuction.FrontendWeb.AuctionsLive do
  use QuickAuction.FrontendWeb, :live_view
  require Logger

  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(QuickAuction.PubSub, "auction_updated")
    end

    user_name = session["user_name"]
    user_id = session["user_id"]

    {:ok,
     socket
     |> assign(:user_name, user_name)
     |> assign(:user_id, user_id)
     |> assign(:auction, %{})}
  end

  def render(assigns) do
    ~H"""
    <h1>Hello <%= @user_name %></h1>
    """
  end

  def handle_info({:auction_updated, auction}, socket) do
    Logger.debug("handle_info :auction_updated #{inspect(auction)}")
    {:noreply, socket}
  end

  # fallback handler
  def handle_info(msg, socket) do
    Logger.debug("handle_info unknown message #{inspect(msg)}")
    {:noreply, socket}
  end
end
