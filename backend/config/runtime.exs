import Config

node_one = System.get_env("NODE_ONE") || "backend@OLOK-PO-265.local"
node_two = System.get_env("NODE_TWO") || "frontend@OLOK-PO-265.local"
node_three = System.get_env("NODE_THREE") || "frontend@OLOK-PO-265.local"

config :libcluster,
  topologies: [
    epmd: [
      strategy: Elixir.Cluster.Strategy.Epmd,
      config: [
        hosts: [
          String.to_atom(node_one),
          String.to_atom(node_two),
          String.to_atom(node_three)
        ]
      ]
    ]
  ]

config :backend, :auctions,
  unit: :second,
  amount: 60

config :backend,
       :products_file,
       System.get_env("PRODUCTS_FILE") || "products_picsum.json"
