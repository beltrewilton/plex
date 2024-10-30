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
      data_list = Plex.Data.get_webhook_data("442392808948818")

      results =
        Task.async_stream(data_list, fn data ->
          conn =
            conn(:post, "/", data)
            |> Router.call(@opts)

          assert conn.status == 200
          assert conn.resp_body == Jason.encode!(%{"status" => "success"})

          :ok
        end, max_concurrency: 50, timeout: :infinity)

      Enum.each(results, fn {:ok, result} -> result end)
    end
  end
end
