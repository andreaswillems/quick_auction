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

  def save_images do
    GenServer.call(__MODULE__, :save_images)
  end

  @impl true
  @spec handle_continue(:read_products, any) :: {:noreply, %{products: list}}
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

  @impl true
  def handle_call(:save_images, _from, %{products: products} = state) do
    image_urls =
      Enum.map(products, fn product -> %{id: product.id, image_url: product.image_url} end)

    IO.inspect(image_urls)

    tasks =
      Enum.map(image_urls, fn %{id: id, image_url: image_url} ->
        Task.async(fn ->
          {:ok, response} = Tesla.get(image_url)
          path = Path.join(["assets", "images", id <> ".jpg"])
          File.write!(path, response.body)
        end)
      end)

    Task.await_many(tasks, 30_000)

    {:reply, image_urls, state}
  end

  defp read_from_file do
    # read product data from file and store in process state
    path_to_file = Application.get_env(:backend, :products_file)

    File.read!(path_to_file)
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
