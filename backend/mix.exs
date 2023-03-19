defmodule QuickAuction.Backend.MixProject do
  use Mix.Project

  def project do
    [
      app: :backend,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {QuickAuction.Backend.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "1.6.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:jason, "1.4.0"},
      {:libcluster, "3.3.2"},
      {:phoenix_pubsub, "2.1.1"},
      {:typed_struct, "0.3.0"},
      {:uniq, "0.5.4"},
      {:tesla, "1.5.1"},
      {:hackney, "1.18.1"}
    ]
  end
end
