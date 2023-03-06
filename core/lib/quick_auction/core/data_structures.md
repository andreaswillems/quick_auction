# QuickAuction.Core

## Data structures

As a _user_, I can see _auctions_ for which I can enter a _bid_.
An auction represents a product, a time the auction ends and a current price.
An auctions starts at a price of 0,01 EUR.
Every active user can see the auction and enter a _bid_ with the _amount_ either 0,01 EUR, 0,10 EUR or 1,00 EUR.
A product can have a name, a description and an image.
A bid is associated to a user and the amount the user selected.

```elixir
# QuickAuction.Core.Data.User
name - String.t

# QuickAuction.Core.Data.Auction
product - Product.t
start_time - Time.t
end_time - Time.t
current_price - Decimal.t
bids - Bid.t

# QuickAuction.Core.Data.Product
name - String.t
description - String.t
image - String.t # URL

# QuickAuction.Core.Data.Bid
user - User.t
amount - Integer.t
auction - Auction.t
```

## Logic

## Tests
