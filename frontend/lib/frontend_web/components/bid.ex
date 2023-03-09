defmodule QuickAuction.FrontendWeb.Components.Bid do
  use Phoenix.Component

  attr :bids, :list, required: true

  def list(assigns) do
    ~H"""
    <div>
      <div :for={bid <- @bids} class="w-full p-4 flex flex-row">
        <div class="flex-grow text-left"><%= bid.user.name %></div>
        |
        <div class="flex-grow text-center"><%= format_amount(bid.amount) %> €</div>
        |
        <div class="flex-grow text-right"><%= format_timestamp(bid.created_at) %></div>
      </div>
    </div>
    """
  end

  defp format_amount(price) when is_integer(price) do
    (price / 100) |> :erlang.float_to_binary(decimals: 2)
  end

  defp format_timestamp(timestamp) do
    timestamp
    |> DateTime.shift_zone!("Europe/Berlin")
    |> DateTime.to_time()
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end
end
