import Config

IO.inspect(System.get_env("PLEX_CFG"), label: "PLEX_CFG")

plex_cfg = System.get_env("PLEX_CFG")

private_key_pem = File.read!("/Users/beltre.wilton/apps/plex/.certs/private_unencrypted.pem")
Application.put_env(:plexgw, :private_key_pem, private_key_pem)

DotenvParser.load_file(plex_cfg)

config :plex, Plex.Repo,
  username: System.get_env("USERNAME"),
  password: System.get_env("DBPASSWORD"),
  database: System.get_env("DATABASE"),
  hostname: System.get_env("HOSTNAME"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
