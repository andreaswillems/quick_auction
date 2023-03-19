defmodule QuickAuction.FrontendWeb.Components.Product do
  use QuickAuction.FrontendWeb, :html

  attr(:product, :map, required: true)

  def info(assigns) do
    ~H"""
    <div>
      <img class="p-6 mx-auto max-h-96" src={@product.image_url} alt="Mountain" />
      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2"><%= @product.name %></div>
        <p class="text-gray-700 text-base">
          <%= @product.description %>
        </p>
      </div>
    </div>
    """
  end
end
