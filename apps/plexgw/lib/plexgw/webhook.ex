defmodule Webhook.Router do
  use Plug.Router

  import Plug.Conn

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  # alias DBConnection.Task
  alias WhatsappElixir.Static, as: WS
  alias Plexgw.Setup

  @source_webhook "WEBHOOK"

  get "/yoh" do
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  get "/" do
    verify_token = conn.query_params["hub.verify_token"]
    local_hook_token = System.get_env("CLOUD_API_TOKEN_VERIFY")

    if verify_token == local_hook_token do
      hub_challenge = conn.query_params["hub.challenge"]
      send_resp(conn, 200, hub_challenge)
    else
      send_resp(conn, 403, "Authentication failed. Invalid Token.")
    end
  end

  post "/" do
    data = conn.body_params
    handle_notification(WS.handle_notification(data), data)

    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  forward("/flow", to: Flow.Router)

  match _ do
    send_resp(conn, 404, "You are trying something that does not exist.")
  end

  def handle_notification(%Whatsapp.Client.Sender{} = data, rawdata) do
    sender = data.sender_request
    waba_id = Keyword.get(sender, :waba_id)

    case Setup.get(waba_id) do
      [_, target_node, :plex_app] ->
        :rpc.cast(
          target_node,
          Plex.State,
          :message_handler,
          [
            waba_id,
            Keyword.get(sender, :sender_phone_number),
            Keyword.get(sender, :message),
            Keyword.get(sender, :wa_message_id),
            Keyword.get(sender, :flow),
            Keyword.get(sender, :audio_id),
            Keyword.get(sender, :scheduled),
            Keyword.get(sender, :forwarded)
          ]
        )

        log_notification(rawdata, waba_id)

      [_, _target_node, :chatbot] ->
        {:chatbot_woot}

      [_, _target_node, :redirect] ->
        {:redirect_to_another_app}

      [_, nil, nil] ->
        {:sorry_no_app}
    end

    IO.puts("Termine esta vuelta!")
  end

  def handle_notification(%Whatsapp.Meta.Request{} = data, rawdata) do
    sender = data.meta_request
    waba_id = Keyword.get(sender, :waba_id)

    log_notification(rawdata, waba_id)

    IO.puts("No redirect for this content .. !")
    IO.inspect(data)
  end

  def handle_notification(_, _) do
    IO.puts("Nothing todo handle_notification !")
  end

  def log_notification(data, waba_id) do
    Task.async(
      fn ->
        Process.sleep(10_000)
        log = %WebHookLog{
          source: @source_webhook,
          response: data,
          waba_id: waba_id
        }
        Plexgw.Data.webhook_log(log)
      end
    )
  end
end

# {time_microseconds, result} = :timer.tc(:rpc, :call, [:"plexcore1@10.0.0.28", Plex.Data, :get_webhook_data, ["442392808948818"]])
# :rpc.call(:"plexcore1@10.0.0.28", Plex.State, :new, ["999", "Hi", "wa", false, nil, false, false])
