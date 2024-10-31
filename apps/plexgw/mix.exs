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
      {:plug_cowboy, "~> 2.7.2"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2.1"},
      {:dotenv_parser, "~> 2.0"},
      {:whatsapp_elixir, path: "/Users/beltre.wilton/apps/whatsapp_elixir"}
    ]
  end
end