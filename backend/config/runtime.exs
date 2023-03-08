import Config

config :libcluster,
  topologies: [
    epmd: [
      strategy: Elixir.Cluster.Strategy.Epmd,
      config: [
        hosts: [:"backend@OLOK-PO-265", :"frontend@OLOK-PO-265"]
      ]
    ]
  ]

# if config_env() == :prod do
# end
