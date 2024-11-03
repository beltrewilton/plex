defmodule Flow.Router do
  use Plug.Router

  import Plug.Conn

  alias WhatsappElixir.Flow

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    IO.inspect("Inside flow.")
    send_resp(conn, 200, "....This is a message from flow")
  end

  post "/register" do



    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  def decrypt_data(data) do
    #TODO: load this file to memory at the beginning
    private_key_pem = File.read!("/Users/beltre.wilton/apps/plex/.certs/private.pem")
    passphrase = System.get_env("PASSPHRASE")
    {:ok, {result, aes_key, iv}} = Flow.decrypt(data, private_key_pem, passphrase)
    waba_id = result["data"]["waba_id"]

    case waba_id do
      [_, target_node, :plex_app] ->
        :rpc.cast(
          target_node,
          Plex.State, #TODO: here call the node with the Flow implementatio
          :new,
          [
            waba_id
          ]
        )

      [_, _target_node, :chatbot] ->
        {:chatbot_woot}

      [_, _target_node, :redirect] ->
        {:redirect_to_another_app}

      [_, nil, nil] ->
        {:sorry_no_app}
    end
  end
end
