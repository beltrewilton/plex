import Config

IO.inspect(System.get_env("PLEX_CFG"), label: "PLEX_CFG")

plex_cfg = System.get_env("PLEX_CFG")

IO.inspect(File.cwd!, label: "current path")

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
  pool_timeout: 50_000,
  queue_target: 50_000,
  queue_interval: 50_000,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  after_connect: {Plex.Repo, :go, []}

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
  pool_timeout: 50_000,
  queue_target: 50_000,
  queue_interval: 50_000,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
