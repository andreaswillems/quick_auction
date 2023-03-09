defmodule QuickAuction.Core.Auction do
  @moduledoc """
  Represents an auction.
  """
  use TypedStruct
  alias QuickAuction.Core.Auction
  alias QuickAuction.Core.{Bid, Product, User}

  typedstruct enforce: true do
    @typedoc "An auction"
    field :id, String.t()
    field :product, Product.t()
    field :start_time, DateTime.t()
    field :end_time, DateTime.t()
    field :current_price, integer()
    field :current_winner, User.t()
    field :bids, list(Bid.t())
  end

  # @spec new(Product.t(), DateTime.t(), DateTime.t()) ::
  #         {:error, :wrong_argument_type} | {:ok, QuickAuction.Core.Auction.t()}
  def new(%Product{} = product, %DateTime{} = start_time, %DateTime{} = end_time)
      when is_struct(product, Product) and is_struct(start_time, DateTime) and
             is_struct(end_time, DateTime) do
    default_auction(product, start_time, end_time)
  end

  # def new(_, _, _), do: {:error, :wrong_argument_type}

  # @spec new(Product.t(), DateTime.t()) ::
  #         {:ok, QuickAuction.Core.Auction.t()} | {:error, :wrong_argument_type}
  def new(%Product{} = product, %DateTime{} = start_time)
      when is_struct(product, Product) and is_struct(start_time, DateTime) do
    end_time = DateTime.add(start_time, 5, :minute)

    default_auction(product, start_time, end_time)
  end

  # def new(_, _), do: {:error, :wrong_argument_type}

  @spec add_bid(Auction.t(), User.t(), integer(), DateTime.t()) ::
          {:error, :wrong_argument_type} | Auction.t()
  def add_bid(%Auction{} = auction, %User{} = user, amount, %DateTime{} = created_at)
      when is_struct(auction, __MODULE__) and is_struct(user, User) and is_integer(amount) do
    {:ok, bid} = Bid.new(user, amount, created_at)
    updated_bids = [bid | auction.bids]

    current_price =
      Enum.reduce(updated_bids, 0, fn entry, acc ->
        entry.amount + acc
      end)

    %{auction | bids: updated_bids, current_price: current_price, current_winner: user}
  end

  def add_bid(_, _, _, _), do: {:error, :wrong_argument_type}

  @spec add_bid(Auction.t(), Bid.t()) ::
          {:error, :wrong_argument_type} | Auction.t()
  def add_bid(%Auction{} = auction, %Bid{} = bid) do
    add_bid(auction, bid.user, bid.amount, bid.created_at)
  end

  def get_winner(auction) when is_struct(auction, __MODULE__) do
    case Enum.empty?(auction.bids) do
      true ->
        {:error, :no_bids}

      false ->
        last_bid = hd(auction.bids)
        {:ok, %{name: last_bid.user.name, end_price: auction.current_price}}
    end
  end

  defp default_auction(product, start_time, end_time) do
    {:ok,
     %__MODULE__{
       id: UUID.uuid4(),
       product: product,
       start_time: start_time,
       end_time: end_time,
       current_price: 0,
       current_winner: %{name: ""},
       bids: []
     }}
  end
end
