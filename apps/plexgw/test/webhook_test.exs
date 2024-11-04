defmodule EntryTest do
  use ExUnit.Case
  ExUnit.configure(timeout: :infinity, seed: 0)

  use Plug.Test

  alias Webhook.Router

  @opts Router.init([])

  @msisdn "18496789003"
  @campaign "CNVQSOUR84FK"
  @client_name "Isaura Constantine"

  setup do
    # Plex.Repo.start_link(timeout: :infinity)
    :ok
  end

  describe "POST /" do
    # test "massive bulk test" do
    #   data_list = Plex.Data.get_webhook_data()

    #   results =
    #     Task.async_stream(
    #       data_list,
    #       fn data ->
    #         conn =
    #           conn(:post, "/", data)
    #           |> Router.call(@opts)

    #         assert conn.status == 200
    #         assert conn.resp_body == Jason.encode!(%{"status" => "success"})

    #         :ok
    #       end,
    #       max_concurrency: 2,
    #       timeout: :infinity
    #     )

    #   Enum.each(results, fn {:ok, result} ->
    #     # IO.inspect(
    #     #    :mnesia.transaction(fn ->  :mnesia.match_object({PlexConfig, :_, :_, :_}) end)
    #     # )
    #     Process.sleep(Enum.random(1500..2500))
    #     result
    #   end)
    # end

    test "welcome" do
      data = Mockdata.text("Hi, this is the promo code CNVQSOUR84FK what's up 💚!", @msisdn)

      conn =
        conn(:post, "/", data)
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == Jason.encode!(%{"status" => "success"})
    end

    test "fill form" do
      data = Mockdata.flow(@msisdn)

      # Plex.Data.register_or_update(@msisdn, @client_name, 1, true, "yes", "yes", "Angeles", @campaign)

      conn =
        conn(:post, "/", data)
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == Jason.encode!(%{"status" => "success"})
    end

    test "simple ask" do
      data = Mockdata.text("Do they offer bonuses for achievements?", @msisdn)

      conn =
        conn(:post, "/", data)
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == Jason.encode!(%{"status" => "success"})
    end

    test "step complete" do
      data = Mockdata.flow(@msisdn)

      conn =
        conn(:post, "/", data)
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == Jason.encode!(%{"status" => "success"})
    end
  end
end
