defmodule Plexgw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Webhook.Router, options: [port: 8000]},
      {Plug.Cowboy, scheme: :http, plug: Redirect.Router, options: [port: 8001]},
      {Task, fn -> Plexgw.Setup.start() end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plexgw.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
