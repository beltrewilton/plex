import Config

if config_env() == :prod do
  import Config

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :plexui, Plexui.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :plexui, Plexui.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :plexui, Plexui.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :plexui, Plexui.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  import Config
  IO.inspect(System.get_env("PLEX_CFG"), label: "PLEX_CFG")

  plex_cfg = System.get_env("PLEX_CFG")

  IO.inspect(File.cwd!(), label: "current path")

  private_key_pem = File.read!("../../.certs/private_unencrypted.pem")
  Application.put_env(:plexgw, :private_key_pem, private_key_pem)

  DotenvParser.load_file(plex_cfg)

  IO.inspect(System.get_env("USERNAME"), label: "USERNAME")
  IO.inspect(System.get_env("DBPASSWORD"), label: "DBPASSWORD")
  IO.inspect(System.get_env("DATABASE"), label: "DATABASE")
  IO.inspect(System.get_env("HOSTNAME"), label: "HOSTNAME")

  config :plex, Plex.Repo,
    username: System.get_env("USERNAME"),
    password: System.get_env("DBPASSWORD"),
    database: System.get_env("DATABASE"),
    hostname: System.get_env("HOSTNAME"),
    show_sensitive_data_on_connection_error: true,
    pool_size: 10

  config :plexui, Plexui.Repo,
    username: System.get_env("USERNAME"),
    password: System.get_env("DBPASSWORD"),
    database: System.get_env("DATABASE"),
    hostname: System.get_env("HOSTNAME"),
    show_sensitive_data_on_connection_error: true,
    pool_size: 10

  DotenvParser.load_file("../../config/plexgw.cfg")

  IO.inspect(System.get_env("GW_USERNAME"), label: "GW_USERNAME")
  IO.inspect(System.get_env("DBPASSWORD"), label: "DBPASSWORD")
  IO.inspect(System.get_env("GW_DATABASE"), label: "GW_DATABASE")
  IO.inspect(System.get_env("GW_HOSTNAME"), label: "GW_HOSTNAME")

  config :plexgw, Plexgw.Repo,
    username: System.get_env("GW_USERNAME"),
    password: System.get_env("GW_DBPASSWORD"),
    database: System.get_env("GW_DATABASE"),
    hostname: System.get_env("GW_HOSTNAME"),
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
end
