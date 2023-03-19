defmodule QuickAuction.BackendTest do
  use ExUnit.Case
  doctest QuickAuction.Backend

  test "greets the world" do
    assert QuickAuction.Backend.hello() == :world
  end
end
