defmodule Plexui.Repo do
    use Ecto.Repo,
        otp_app: :plexui,
        adapter: Ecto.Adapters.Postgres
end
