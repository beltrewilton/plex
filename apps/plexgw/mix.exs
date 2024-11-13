defmodule Plexgw.MixProject do
  use Mix.Project

  def project do
    [
      app: :plexgw,
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
      mod: {Plexgw.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19.1"},
      {:plug_cowboy, "~> 2.7.2"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2.1"},
      {:dotenv_parser, "~> 2.0"},
      {:tzdata, "~> 1.1"},
      # {:whatsapp_elixir, path: "/Users/beltre.wilton/apps/whatsapp_elixir"}
      {:whatsapp_flow_crypto, path: "/home/wilton/plex_env/whatsapp_elixir"}
    ]
  end
end
