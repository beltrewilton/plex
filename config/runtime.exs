IO.puts("Aqui custom secret file por node-tenant")
IO.puts(System.get_env("CUSTOM_SECRET"))

private_key_pem = File.read!("/Users/beltre.wilton/apps/plex/.certs/private_unencrypted.pem")
Application.put_env(:plexgw, :private_key_pem, private_key_pem)

if Mix.env() == :test do
  DotenvParser.load_file("../../.secret")
else
  DotenvParser.load_file("../../.secret")
end
