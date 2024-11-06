import Config

IO.inspect(System.get_env("PLEX_CFG"), label: "PLEX_CFG")

plex_cfg = System.get_env("PLEX_CFG")

IO.inspect(File.cwd!, label: "current path")

private_key_pem = File.read!("../../.certs/private_unencrypted.pem")
Application.put_env(:plexgw, :private_key_pem, private_key_pem)

DotenvParser.load_file(plex_cfg)

config :plex, Plex.Repo,
  username: System.get_env("USERNAME"),
  password: System.get_env("DBPASSWORD"),
  database: System.get_env("DATABASE"),
  hostname: System.get_env("HOSTNAME"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

DotenvParser.load_file("../../config/plexgw.cfg")

config :plexgw, Plexgw.Repo,
  username: System.get_env("GW_USERNAME"),
  password: System.get_env("GW_DBPASSWORD"),
  database: System.get_env("GW_DATABASE"),
  hostname: System.get_env("GW_HOSTNAME"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
