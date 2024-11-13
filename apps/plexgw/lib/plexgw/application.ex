defmodule Plexgw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plexgw.Repo, []},
      {Plug.Cowboy, scheme: :http, plug: Webhook.Router, options: [port: 9091]},
      {Plug.Cowboy, scheme: :http, plug: Redirect.Router, options: [port: 9092]},
      {Plug.Cowboy, scheme: :http, plug: AudioSrv.Router, options: [port: 8010]},
      {Task, fn -> Plexgw.Setup.start() end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plexgw.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
