defmodule QuickAuction.FrontendWeb.Components.Auction do
  use Phoenix.Component

  attr :start_time, :map, required: true
  attr :end_time, :map, required: true
  attr :current_price, :float, required: true
  attr :current_winner, :map, required: true

  def info(assigns) do
    ~H"""
    <div class="px-6 pt-4 pb-2 w-full">
      <div class="flex flex-row text-l mb-2">
        <div class="font-bold">Auction started at</div>
        <div class="flex-grow text-right"><%= format_timestamp(@start_time) %></div>
      </div>
      <div class="flex flex-row text-l mb-2">
        <div class="font-bold">Auction ends at</div>
        <div class="flex-grow text-right"><%= format_timestamp(@end_time) %></div>
      </div>
      <div class="flex flex-row text-l mb-2">
        <div class="font-bold">Current price</div>
        <div class="flex-grow text-right"><%= format_amount(@current_price) %> €</div>
      </div>
      <div class="flex flex-row text-l mb-2">
        <div class="font-bold">Highest bidder:</div>
        <div class="flex-grow text-right"><%= format_winner(@current_winner) %></div>
      </div>
    </div>
    """
  end

  def activity_indicator(assigns) do
    ~H"""
    <div class="border border-slate-800 rounded-lg px-4 py-3 mx-0 shadow-outline">
      <svg
        class={["animate-spin h-5 w-5 mx-auto"]}
        width="100"
        height="100"
        viewBox="0 0 22 22"
        xmlns="http://www.w3.org/2000/svg"
        stroke="#1e293b"
      >
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
    """
  end

  attr :title, :string, required: true
  attr :event_name, :string, required: true
  attr :event_value, :string, required: true

  def bid_button(assigns) do
    ~H"""
    <button
      phx-click={@event_name}
      phx-value-amount={@event_value}
      phx-throttle="5000"
      class="bg-white flex-grow text-slate-800 hover:bg-slate-800 hover:text-white border border-slate-800 rounded-lg px-4 py-2 mx-0 outline-none focus:shadow-outline"
    >
      <span><%= @title %> €</span>
    </button>
    """
  end

  defp format_timestamp(timestamp) do
    timestamp
    |> DateTime.shift_zone!("Europe/Berlin")
    |> DateTime.to_time()
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end

  defp format_amount(price) when is_integer(price) do
    (price / 100) |> :erlang.float_to_binary(decimals: 2)
  end

  defp format_winner(user) when is_map(user) do
    if String.trim(user.name) == "" do
      "-"
    else
      user.name
    end
  end
end
