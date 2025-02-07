defmodule Plexui.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Plexui.Telemetry,
      # Start a worker by calling: Plexui.Worker.start_link(arg)
      # {Plexui.Worker, arg},
      # Start to serve requests, typically the last entry
      {Phoenix.PubSub, name: Plexui.PubSub},
      Plexui.Endpoint,
      {Plexui.Repo, []} 
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plexui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Plexui.Endpoint.config_change(changed, removed)
    :ok
  end
end
