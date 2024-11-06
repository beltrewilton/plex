defmodule Plexgw.Repo do
  use Ecto.Repo,
    otp_app: :plexgw,
    adapter: Ecto.Adapters.Postgres
end
