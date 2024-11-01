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
      # TODO: works for --no-halt recipe.
      {Plex.Repo, []},
      {Task, fn -> Plex.Data.start_link([]) end}
    ]

    Logger.info("Webhook & Plex.Data")
    Logger.info(Node.get_cookie())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
