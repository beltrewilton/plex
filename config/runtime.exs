IO.puts("Aqui custom secret file por node-tenant")
IO.puts(System.get_env("CUSTOM_SECRET"))

if Mix.env() == :test do
  DotenvParser.load_file("../../.secret")
else
  DotenvParser.load_file("../../.secret")
end
