defmodule PlexCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :plexcore,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
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
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2.1"},
      {:dotenv_parser, "~> 2.0"},
      {:bumblebee, "~> 0.6.0"},
      {:exla, "~> 0.9.1"},
      #   TODO: this is for test -- remove...
      {:plug_cowboy, "~> 2.7.2"},
      {:whatsapp_elixir, path: "/Users/beltre.wilton/apps/whatsapp_elixir"}
    ]
  end
end
