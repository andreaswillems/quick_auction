defmodule QuickAuction.Core.Data.Bid do
  @moduledoc false
  use TypedStruct
  alias QuickAuction.Core.Data.{Auction, User}

  typedstruct enforce: true do
    @typedoc "A bid"
    field :auction, Auction.t()
    field :user, User.t()
    field :amount, integer()
  end

  def new(auction, user, amount) when is_struct(auction, Auction) and is_struct(user, User) and is_integer(amount) do
    %__MODULE__{auction: auction, user: user, amount: amount}
  end
  def new(_, _, _), do: {:error, :wrong_argument_type}
end
