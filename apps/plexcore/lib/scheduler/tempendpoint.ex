defmodule Scheduler.Tempendpoint do
  use Plug.Router
  alias alias Plex.Scheduler

  import Plug.Conn

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/schedule" do
    msisdn = conn.query_params["msisdn"]
    campaign = conn.query_params["campaign"]

    Scheduler.calcel_execution(
      msisdn,
      campaign,
      "_message_firer_job"
    )

    Scheduler.schedule(
      msisdn,
      campaign,
      "_message_firer_job",
      fn ->
        IO.puts("Hey this is was scheduled with #{msisdn}.")

        Scheduler.calcel_execution(
          msisdn,
          campaign,
          "_message_firer_job"
        )
      end,
      15_000
    )

    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  # Plex.Data.Memory.get_ref("18095557001", "PRICHAMP", "_message_firer_job")

  get "/cancel" do
    msisdn = conn.query_params["msisdn"]
    campaign = conn.query_params["campaign"]

    Scheduler.calcel_execution(
      msisdn,
      campaign,
      "_message_firer_job"
    )

    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end
end
