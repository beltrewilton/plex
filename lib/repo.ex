defmodule Machinery.Repo do
  use Ecto.Repo,
    otp_app: :plex,
    adapter: Ecto.Adapters.Postgres
    
end
