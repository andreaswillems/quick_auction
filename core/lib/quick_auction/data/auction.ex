defmodule QuickAuction.Core.Data.Auction do
  @moduledoc false
  use TypedStruct
  alias QuickAuction.Core.Data.{Bid, Product}

  typedstruct enforce: true do
    @typedoc "An auction"
    field :product, Product.t()
    field :start_time, DateTime.t()
    field :end_time, DateTime.t()
    field :current_price, Float.t()
    field :bids, list(Bid.t())
  end

end
