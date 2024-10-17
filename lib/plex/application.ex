defmodule Plex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Plex.Worker.start_link(arg)
      # {Plex.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Webhook.Router, options: [port: 8000]},
      {Task, fn -> Machinery.Data.start_link() end}
      # {Venomous.SnakeSupervisor, [strategy: :one_for_one, max_restarts: 0, max_children: 50]},
      # {Venomous.PetSnakeSupervisor, [strategy: :one_for_one, max_children: 10]}
      # {Plug.Cowboy, scheme: :http, plug: Flow.Router,    options: [port: 9000]},
      # Protohackers.EchoServer,
    ]

    Logger.info("Webhook and other components")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plex.Supervisor]
    # opts = [strategy: :one_for_one, name: PetSnakeSupervisor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
