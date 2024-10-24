defmodule Plex.MixProject do
  use Mix.Project

  def project do
    [
      app: :plex,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools, :mnesia],
      mod: {Plex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:venomous, "~> 0.7.1"},
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19.1"},
      {:export, "~> 0.1.1"},
      {:erlport, "~> 0.11.0"},
      {:plug_cowboy, "~> 2.7.2"  },
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2.1"},
      {:dotenv_parser, "~> 2.0"}
    ]
  end
end
