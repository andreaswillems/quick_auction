defmodule QuickAuction.Core.Data.Product do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    @typedoc "A product"

    field :name, String.t()
    field :description, String.t()
    field :image_url, String.t()
  end

  @spec new(String.t(), String.t(), String.t()) ::
          {:error, :wrong_argument_type} | {:ok, QuickAuction.Core.Data.Product.t()}
  def new(name, description, image_url)
      when is_binary(name) and is_binary(description) and is_binary(image_url) do
    {:ok, %__MODULE__{name: name, description: description, image_url: image_url}}
  end

  def new(_, _, _), do: {:error, :wrong_argument_type}
end
