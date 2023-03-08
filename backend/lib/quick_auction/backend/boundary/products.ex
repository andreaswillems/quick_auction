defmodule QuickAuction.Backend.Boundary.Products do
  use GenServer
  require Logger
  alias QuickAuction.Core.Product

  def start_link(args) do
    Logger.debug("start_link")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.debug("init")
    {:ok, [], {:continue, :read_products}}
  end

  def random do
    GenServer.call(__MODULE__, :random_product)
  end

  @impl true
  def handle_continue(:read_products, _state) do
    Logger.debug("handle_continue :read_products")
    products = read_from_file()
    {:noreply, %{products: products}}
  end

  @impl true
  def handle_call(:random_product, _from, %{products: products} = state) do
    product = fetch_random_product(products)
    {:reply, product, state}
  end

  defp read_from_file do
    # read product data from file and store in process state
    File.read!("products_2.json")
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(&to_product/1)
  end

  defp to_product(entry) when is_map(entry) do
    {:ok, product} = Product.new(entry.title, entry.description, entry.image)
    product
  end

  # pick random product from process state
  defp fetch_random_product(products) when length(products) > 0, do: Enum.random(products)
  defp fetch_random_product([]), do: :error
end
