import Config

config :logger, :console,
  format: "[$level][$time] $metadata $message\n",
  metadata: [:file, :line]

config :backend, :auctions,
  unit: :second,
  amount: 60

config :backend, pubsub_name: QuickAuction.PubSub

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{config_env()}.exs"
