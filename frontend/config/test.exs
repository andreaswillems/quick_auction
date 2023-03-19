import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :frontend, QuickAuction.FrontendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v3g7Wrhu20wNnXZHJviNhRZiiNm/Fz9MRUqVJWasAS+Vb60G8zuwlJdSDLgqPp3M",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
