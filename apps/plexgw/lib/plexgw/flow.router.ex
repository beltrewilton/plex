defmodule Flow.Router do
  use Plug.Router

  import Plug.Conn

  alias WhatsappElixir.Flow
  alias Plexgw.Setup

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    IO.inspect(conn.body_params)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  post "/" do
    IO.inspect(conn.body_params)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  post "/register" do
    response = handle_request(conn.body_params, :register)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, response)
  end

  post "/assessment" do
    response = handle_request(conn.body_params, :assessment)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, response)
  end

  post "/scheduler" do
    response = handle_request(conn.body_params, :scheduler)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, response)
  end

  def handle_request(data, remote_function) do
    # TODO: load this file to memory at the beginning
    private_key_pem = File.read!("/Users/beltre.wilton/apps/plex/.certs/private_unencrypted.pem")
    passphrase = System.get_env("PASSPHRASE")

    {:ok, {decrypted_data, aes_key, iv}} = Flow.decrypt(data, private_key_pem, passphrase)

    IO.inspect(decrypted_data)

    handle_action(decrypted_data["action"], remote_function, decrypted_data, aes_key, iv)
  end

  def handle_action("ping", _remote_function, decrypted_data, aes_key, iv) do
    response = %{
      "version" => decrypted_data["version"],
      "data" => %{"status" => "active"}
    }

    Flow.encrypt(response, aes_key, iv)
  end

  def handle_action("INIT", remote_function, decrypted_data, aes_key, iv) do
    screen =
      case remote_function do
        :register -> "APPLICANT_BASIC"
        :assessment -> "APPLICANT_ASSESSMENT_ONE"
        :scheduler -> "APPLICANT_SCHEDULER"
        _ -> "UNKNOW"
      end

    response = %{
      "version" => decrypted_data["version"],
      "screen" => screen,
      "data" => %{}
    }

    Flow.encrypt(response, aes_key, iv)
  end

  def handle_action("data_exchange", remote_function, decrypted_data, aes_key, iv) do
    waba_id = decrypted_data["data"]["waba_id"]

    case Setup.get(waba_id) do
      [_, target_node, :plex_app] ->
        if remote_function == :scheduler and
             Map.get(decrypted_data["data"], "trigger", nil) == "period_selected" do
          times =
            case decrypted_data["data"]["period"] do
              "morning" -> TimeHelper.get_times(6, 6, "AM")
              "afternoon" -> TimeHelper.get_times(12, 6, "PM")
              "night" -> TimeHelper.get_times(7, 5, "PM")
              _ -> TimeHelper.get_times(7, 5, "PM")
            end

          response = %{
            "version" => decrypted_data["version"],
            "screen" => "APPLICANT_SCHEDULER",
            "data" => %{
              "time" => times,
              "is_time_enabled" => true
            }
          }

          Flow.encrypt(response, aes_key, iv)
        else
          :rpc.cast(
            target_node,
            Plex.Flow,
            remote_function,
            [
              decrypted_data
            ]
          )

          response = %{
            "version" => decrypted_data["version"],
            "action" => decrypted_data["action"],
            "screen" => "SUCCESS",
            "data" => %{
              "extension_message_response" => %{
                "params" => %{
                  "flow_token" => decrypted_data["flow_token"]
                }
              }
            }
          }

          Flow.encrypt(response, aes_key, iv)
        end

      [_, _target_node, :chatbot] ->
        {:chatbot_woot}

      [_, _target_node, :redirect] ->
        {:redirect_to_another_app}

      [_, nil, nil] ->
        {:sorry_no_app}
    end
  end
end
