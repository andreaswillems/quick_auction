defmodule QuickAuction.CoreTest do
  use ExUnit.Case
  doctest QuickAuction.Core

  test "greets the world" do
    assert QuickAuction.Core.hello() == :world
  end
end
