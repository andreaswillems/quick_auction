defmodule QuickAuction.FrontendWeb.Components.User do
  use QuickAuction.FrontendWeb, :html

  attr(:name, :string, required: true)

  def info(assigns) do
    ~H"""
    <div>
      <h1>Hello <%= @name %></h1>
    </div>
    """
  end

  attr(:user_id, :string, required: true)
  attr(:users, :list, required: true)

  def list(assigns) do
    ~H"""
    <h2 class="text-center text-lg font-bold">Users online</h2>
    <div :for={{id, user} <- sort_users(@users, @user_id)} class="p-2 w-full">
      <%= if @user_id == id do %>
      <div class="w-full text-center text-m bg-green-200 rounded px-2 py-1"><%= user.name %> (me)</div>
      <% else %>
      <div class="w-full text-center text-m bg-blue-200 rounded px-2 py-1"><%= user.name %></div>
      <% end %>
    </div>
    """
  end

  defp sort_users(users, user_id) do
    me = Enum.find(users, fn {id, _user} -> id == user_id end)
    others = Enum.reject(users, fn {id, _user} -> id == user_id end)

    [me | others]
  end
end
