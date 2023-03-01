defmodule QuickAuction.Core.Data.Product do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    @typedoc "A product"

    field :name, String.t()
    field :description, String.t()
    field :image_url, String.t()
  end
end
