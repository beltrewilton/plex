import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :plexui, Plexui.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JHl8kWYHSelt/Ih8UBYN82paJF49MGpj67d6Fxk5B1UqfEm/avXVSut9pdaB7ztk",
  server: false
