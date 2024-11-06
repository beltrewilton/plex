defmodule Redirect.Router do
  use Plug.Router

  import Plug.Conn

  alias Plexgw.Setup

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/redirect/:campaign/:waba_id" do
    try do
      referer = get_req_header(conn, "referer") |> List.first()
      user_agent = get_req_header(conn, "user-agent") |> List.first()

      IO.inspect(referer, label: "referer")
      IO.inspect(user_agent, label: "user_agent")

      IO.inspect(Setup.get(waba_id), label: "Setup: ")

      log = %CTALog{
        referer: referer,
        user_agent: user_agent,
        campaign: campaign,
        waba_id: waba_id
      }

      Task.async(
        fn ->
          Plexgw.Data.cta_log(log)
        end
      )

      case Setup.get(waba_id) do
        [_, target_node, :plex_app] ->
          {:ok, record} =
            :rpc.call(
              target_node,
              Plex.Data,
              :get_job_by_campaign,
              [
                campaign
              ]
            )

          IO.inspect(record, label: "rpc call record:")

          whatsapp_url =
            "https://api.whatsapp.com/send?phone=#{record.wa_phone}&text=#{record.wa_text}"

          conn
          |> put_resp_header("location", whatsapp_url)
          |> send_resp(302, "")

        [_, _target_node, :chatbot] ->
          {:chatbot_woot}

        [_, _target_node, :redirect] ->
          {:redirect_to_another_app}

        [_, nil, nil] ->
          {:sorry_no_app}
      end

      # send_resp(conn, 200, Jason.encode!(%{"campaign" => campaign, "waba_id" => waba_id}))
    rescue
      e ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(
          500,
          Jason.encode!(%{error: "Internal Server Error", detail: Exception.message(e)})
        )
    end
  end
end
