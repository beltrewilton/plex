if Mix.env() == :test do
  DotenvParser.load_file("../../.secret")
else
  DotenvParser.load_file("../../.secret")
end
