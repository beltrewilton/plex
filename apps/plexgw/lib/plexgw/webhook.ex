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
    notification = WhatsappElixir.Static.handle_notification(conn.body_params.response)

    handle_notification(notification)

    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  forward("/subtask", to: Subtask.Router)

  match _ do
    send_resp(conn, 404, "You are trying something that does not exist.")
  end

  # def new(
  #       msisdn,
  #       message,
  #       whatsapp_id,
  #       flow,
  #       audio_id,
  #       scheduled,
  #       forwarded,
  #       task \\ :talent_entry_form,
  #       state \\ :in_progress
  #     ) do
  def handle_notification(%Whatsapp.Client.Sender{} = sender) do
    sender = sender.sender_request
    waba_id = Keyword.get(sender, :waba_id)

    case Plexgw.Setup.get(waba_id) do
      [_, target_node, :plex_app] ->
        IO.inspect(
          :rpc.call(
            target_node,
            Plex.State,
            :new,
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
        )

      [_, _target_node, :chatbot] ->
        {:chatbot_woot}

      [_, _target_node, :redirect] ->
        {:redirect_to_another_app}

      [_, nil, nil]  -> {:sorry_no_app}
    end
  end

  def handle_notification(%Whatsapp.Meta.Request{} = meta_request) do
    IO.puts("No redirect for this content .. !")
    IO.inspect(meta_request)
  end

  def handle_notification(_) do
    IO.puts("Nothing todo handle_notification !")
  end
end

# {time_microseconds, result} = :timer.tc(:rpc, :call, [:"plexcore1@10.0.0.28", Plex.Data, :get_webhook_data, ["442392808948818"]])
# :rpc.call(:"plexcore1@10.0.0.28", Plex.State, :new, ["999", "Hi", "wa", false, nil, false, false])
