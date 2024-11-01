defmodule SpeechTest do
  use ExUnit.Case
  ExUnit.configure(timeout: :infinity, seed: 0)

  setup do
    # Plex.Repo.start_link()
    :ok
  end

  describe "The short happy path" do
    test "speech super" do
      SpeechSuperClient.test()
    end
  end
end
