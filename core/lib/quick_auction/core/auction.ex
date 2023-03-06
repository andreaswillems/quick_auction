defmodule QuickAuction.Core.Auction do
  @moduledoc false
  use TypedStruct
  alias QuickAuction.Core.{Bid, Product, User}

  typedstruct enforce: true do
    @typedoc "An auction"
    field :product, Product.t()
    field :start_time, DateTime.t()
    field :end_time, DateTime.t()
    field :current_price, float()
    field :bids, list(Bid.t())
  end

  def new(product, start_time, end_time)
      when is_struct(product, Product) and is_struct(start_time, DateTime) and
             is_struct(end_time, DateTime) do
    {:ok,
     %__MODULE__{
       product: product,
       start_time: start_time,
       end_time: end_time,
       current_price: 0,
       bids: []
     }}
  end

  def new(product, start_time)
      when is_struct(product, Product) and is_struct(start_time, DateTime) do
    end_time = DateTime.add(start_time, 5, :minute)

    {:ok,
     %__MODULE__{
       product: product,
       start_time: start_time,
       end_time: end_time,
       current_price: 0,
       bids: []
     }}
  end

  def new(_, _), do: {:error, :wrong_argument_type}

  def add_bid(auction, user, amount, created_at)
      when is_struct(auction, __MODULE__) and is_struct(user, User) and is_integer(amount) do
    {:ok, bid} = Bid.new(user, amount, created_at)
    updated_bids = [bid | auction.bids]

    current_price_integer =
      Enum.reduce(updated_bids, 0, fn entry, acc ->
        entry.amount + acc
      end)

    current_price = current_price_integer / 100

    %{auction | bids: updated_bids, current_price: current_price}
  end

  def add_bid(_, _, _, _), do: {:error, :wrong_argument_type}

  def get_winner(auction) when is_struct(auction, __MODULE__) do
    case Enum.empty?(auction.bids) do
      true ->
        {:error, :no_bids}

      false ->
        last_bid = hd(auction.bids)
        {:ok, %{name: last_bid.user.name, end_price: auction.current_price}}
    end
  end
end
