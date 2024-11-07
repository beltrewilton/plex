defmodule Util.Timez do

  @tz Application.get_env(:plex, :default_timezone, "Etc/UTC")

  def now() do
    DateTime.now!(@tz) |> DateTime.to_naive()
  end

  def now(seconds_to_add \\ 0, p \\ :second) do
    DateTime.now!(@tz)
    |> DateTime.add(seconds_to_add, p)
    |> DateTime.to_naive()
  end

end
