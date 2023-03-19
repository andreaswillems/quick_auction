defmodule QuickAuction.Backend do
  @moduledoc """
  Documentation for `QuickAuction.Backend`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> QuickAuction.Backend.hello()
      :world

  """
  def hello do
    :world
  end

  def simulate_bid do
    {:ok, user} = QuickAuction.Core.User.new("Andreas")
    IO.inspect(user)
    # auction = QuickAuction.Backend.Boundary.Auctions.current()
    {:ok, bid} = QuickAuction.Core.Bid.new(user, 10, DateTime.utc_now())
    IO.inspect(bid)

    QuickAuction.Backend.Boundary.Auctions.put_bid(bid)
  end
end
