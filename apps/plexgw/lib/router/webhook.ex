defmodule Webhook.Router do
  use Plug.Router

  import Plug.Conn

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)


  get "/" do
    verify_token = conn.query_params["hub.verify_token"]
    local_hook_token = System.get_env("WHATSAPP_HOOK_TOKEN")
    if verify_token == local_hook_token do
      hub_challenge = conn.query_params["hub.challenge"]
      send_resp(conn, 200, hub_challenge)
    else
      send_resp(conn, 403, "Authentication failed. Invalid Token.")
    end
  end

  post "/" do
    client = WhatsappElixir.Static.handle_notification(conn.body_params.response)
    IO.inspect(client)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  forward("/subtask", to: Subtask.Router)

  match _ do
    send_resp(conn, 404, "You are trying something that does not exist.")
  end
end

# {time_microseconds, result} = :timer.tc(:rpc, :call, [:"plexcore1@10.0.0.28", Plex.Data, :get_webhook_data, ["442392808948818"]])
