defmodule Plexui.Router do
  use Plexui, :router

  pipeline :browser do
    plug Corsica, origins: "*"
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Plexui.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Plexui do
    pipe_through :browser

    get "/:msisdn/:campaign", PageController, :home

    get "/report", PageController, :report
  end

  # Other scopes may use custom stacks.
  # scope "/api", Plexui do
  #   pipe_through :api
  # end
end
