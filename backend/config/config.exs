import Config

config :logger, :console,
  format: "[$level][$time] $metadata $message\n",
  metadata: [:file, :line]

config :backend, :auctions,
  unit: :second,
  amount: 60
