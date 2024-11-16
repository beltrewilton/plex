defmodule SpeechSuperClient do
  @appi_url "https://api.speechsuper.com/"

  defstruct params: %{
              para_eval: "para.eval",
              speak_eval_pro: "speak.eval.pro",
              ielts_part1: "ielts_part1",
              ielts_part2: "ielts_part2",
              ielts_part3: "ielts_part3"
            }

  # Change the audio type corresponding to the audio file.
  @audioType "wav"
  @audioSampleRate 16_000
  @userId "synaia"

  def test(wav \\ "priscila2-b-C1.wav") do
    s = struct(SpeechSuperClient).params

    text =
      "In my previous role at a call center, I managed customer inquiries and resolved issues efficiently. I utilized active listening and problem-solving skills to enhance customer satisfaction. My ability to handle high-stress situations and maintain a professional demeanor contributed to a positive customer experience. This role honed my communication and multitasking abilities."

    request_scripted(
      "#{System.get_env("AUDIO_RECORDING_PATH")}/waves/#{wav}",
      s.para_eval,
      text
    )
  end

  def test_spon(wav \\ "Mario.wav") do
    s = struct(SpeechSuperClient).params

    question_prompt =
      "Describe a film character played by an actor/actress whom you admire."

    request_spontaneous_unscripted(
      "#{System.get_env("AUDIO_RECORDING_PATH")}/unscripted/#{wav}",
      s.speak_eval_pro,
      question_prompt,
      s.ielts_part3
    )
  end

  defp prepare_params do
    speechace_api_key = System.get_env("SPEECHACE_API_KEY")
    speech_super_app_id = System.get_env("SPEECH_SUPER_APP_ID")
    speech_super_key = System.get_env("SPEECH_SUPER_KEY")

    timestamp = System.system_time(:second) |> Integer.to_string()

    connectStr = speech_super_app_id <> timestamp <> speech_super_key
    connectSig = :crypto.hash(:sha, connectStr) |> Base.encode16() |> String.downcase()

    startStr = speech_super_app_id <> timestamp <> @userId <> speech_super_key
    startSig = :crypto.hash(:sha, startStr) |> Base.encode16() |> String.downcase()

    # Define the params map
    %{
      "connect" => %{
        "cmd" => "connect",
        "param" => %{
          "sdk" => %{
            "version" => 16_777_472,
            "source" => 9,
            "protocol" => 2
          },
          "app" => %{
            "applicationId" => speech_super_app_id,
            "sig" => connectSig,
            "timestamp" => timestamp
          }
        }
      },
      "start" => %{
        "cmd" => "start",
        "param" => %{
          "app" => %{
            "userId" => @userId,
            "applicationId" => speech_super_app_id,
            "timestamp" => timestamp,
            "sig" => startSig
          },
          "audio" => %{
            "audioType" => @audioType,
            "channel" => 1,
            "sampleBytes" => 2,
            "sampleRate" => @audioSampleRate
          }
        }
      }
    }
  end

  def request_scripted(audio_path, coreType, refText) do
    synaia_token_id = System.get_env("SYNAIA_TOKEN_ID")

    url = @appi_url <> coreType

    params = prepare_params()

    params =
      put_in(
        params,
        ["start", "param", "request"],
        %{
          "coreType" => coreType,
          "refText" => refText,
          "tokenId" => synaia_token_id,
          "precision" => 0.1
        }
      )

    data = Jason.encode!(params)

    headers = %{"Request-Index" => "0"}

    files = %{audio: File.read!(audio_path)}

    response =
      HTTPoison.post(
        url,
        {:multipart,
         [
           {"text", data},
           {"audio", files.audio, [{"filename", Path.basename(audio_path)}]}
         ]},
        headers,
        recv_timeout: :timer.seconds(180),
        timeout: :timer.seconds(180)
      )

      case response do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}

        {:ok, %HTTPoison.Response{status_code: status_code}} ->
          {:error, "Failed with status code #{status_code}"}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end
  end

  def request_spontaneous_unscripted(audio_path, coreType, question_prompt, task_type) do
    synaia_token_id = System.get_env("SYNAIA_TOKEN_ID")

    url = @appi_url <> coreType

    params = prepare_params()

    params =
      put_in(
        params,
        ["start", "param", "request"],
        %{
          "coreType" => coreType,
          # "tokenId",
          "tokenId" => synaia_token_id,
          "precision" => 0.1,
          "question_prompt" => question_prompt,
          "test_type" => "ielts",
          # ielts_part1, ielts_part2, ielts_part3
          "task_type" => task_type,
          # Return linking, loss of plosion and phoneme-level scores in the results
          "phoneme_output" => 0,
          "model" => "non_native",
          # To penalize irrelevant response
          "penalize_offtopic" => 1,
          "decimal_point" => 1
        }
      )

    data = Jason.encode!(params)

    headers = %{"Request-Index" => "0"}

    files = %{audio: File.read!(audio_path)}

    response =
      HTTPoison.post(
        url,
        {:multipart,
         [
           {"text", data},
           {"audio", files.audio, [{"filename", Path.basename(audio_path)}]}
         ]},
        headers,
        recv_timeout: :timer.seconds(180),
        timeout: :timer.seconds(180)
      )

      case response do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}

        {:ok, %HTTPoison.Response{status_code: status_code}} ->
          {:error, "Failed with status code #{status_code}"}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end
  end

  def test_send() do
    config = [
      token: System.get_env("CLOUD_API_TOKEN"),
      phone_number_id: System.get_env("CLOUD_API_PHONE_NUMBER_ID"),
      verify_token: "",
      base_url: "https://graph.facebook.com",
      api_version: "v20.0"
    ]

    WhatsappElixir.Messages.send_message(
      "18296456177",
      "Hi from Elixir",
      config
    )
  end
end
