defmodule QuickAuction.FrontendWeb.Components.Product do
  use Phoenix.Component

  attr(:product, :map, required: true)

  def info(assigns) do
    ~H"""
    <div class="grid grid-cols-2">
      <div class="m-auto bg-cover text-center overflow-hidden">
        <img class="min-h-96 max-h-96" src={@product.image_url} alt="Product Image" />
      </div>

      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2"><%= @product.name %></div>
        <p class="text-gray-700 text-base">
          <%= @product.description %>
        </p>
      </div>
    </div>
    """
  end

  defp background_image(product) do
    "background-image: url('#{product.image_url}')"
  end
end
