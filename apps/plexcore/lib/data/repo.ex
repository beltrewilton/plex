defmodule Plex.Repo do
  use Ecto.Repo,
    otp_app: :plex,
    adapter: Ecto.Adapters.Postgres

  def go(_) do
    IO.puts("HE RRE HERE HERE ")
  end
end
