defmodule PlexTest do
  use ExUnit.Case
  doctest Plex

  test "greets the world" do
    assert Plex.hello() == :world
  end
end
