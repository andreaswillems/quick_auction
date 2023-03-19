defmodule QuickAuction.Backend.Boundary.Users do
  use GenServer
  alias QuickAuction.Core.User

  @pubsub_name Application.compile_env!(:backend, :pubsub_name)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{}, {:continue, :register_subscribers}}
  end

  def handle_continue(:register_subscribers, users) do
    Phoenix.PubSub.subscribe(@pubsub_name, "user_entered")
    {:noreply, users}
  end

  def handle_info({:user_entered, %User{} = user}, users) do
    updated = Map.put(users, user.id, user)
    {:noreply, updated}
  end

  def handle_info({:user_left, %User{} = user}, users) do
    updated = Map.drop(users, [user.id])
    {:noreply, updated}
  end
end
