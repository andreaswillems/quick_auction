defmodule QuickAuction.CoreTest do
  use ExUnit.Case
  doctest QuickAuction.Core
  alias QuickAuction.Core.{Auction, Bid, Product, User}

  test "greets the world" do
    assert QuickAuction.Core.hello() == :world
  end

  test "making a bid adds it to the auction" do
    {:ok, product} = Product.new("Macbook Pro", "A laptop", "http://image.de/1")
    start_time = DateTime.utc_now()
    {:ok, auction} = Auction.new(product, start_time)
    {:ok, user} = User.new("User1")

    assert auction.end_time == start_time |> DateTime.add(5, :minute)
    assert Enum.count(auction.bids) == 0

    auction = Auction.add_bid(auction, user, 100, DateTime.utc_now())

    assert Enum.count(auction.bids) == 1
    assert auction.current_price == 100
  end

  test "the last bid wins" do
    {:ok, product} = Product.new("Macbook Pro", "A laptop", "http://image.de/1")
    start_time = DateTime.utc_now()
    {:ok, auction} = Auction.new(product, start_time)
    {:ok, user1} = User.new("User1")
    {:ok, user2} = User.new("User2")
    auction = Auction.add_bid(auction, user1, 100, DateTime.utc_now())
    auction = Auction.add_bid(auction, user2, 100, DateTime.utc_now())

    {:ok, winner} = Auction.get_winner(auction)
    assert winner.name == "User2"
    assert winner.end_price == 200
  end
end
