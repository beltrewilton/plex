defmodule EntryTest do
  use ExUnit.Case
  ExUnit.configure([timeout: :infinity, seed: 0])

  use Plug.Test

  alias Webhook.Router

  @opts Router.init([])

  setup do
    Plex.Repo.start_link([timeout: :infinity])
    :ok
  end

  describe "POST /" do
    test "returns a successful response" do
      data_list = Plex.Data.get_webhook_data()

      results =
        Task.async_stream(data_list, fn data ->
          conn =
            conn(:post, "/", data)
            |> Router.call(@opts)

          assert conn.status == 200
          assert conn.resp_body == Jason.encode!(%{"status" => "success"})

          :ok
        end, max_concurrency: 2, timeout: :infinity)

      Enum.each(results, fn {:ok, result} ->
        # IO.inspect(
        #    :mnesia.transaction(fn ->  :mnesia.match_object({PlexConfig, :_, :_, :_}) end)
        # )
        Process.sleep(Enum.random(1500..2500))
        result
      end)
    end
  end
end
