defmodule Integration.MetaEvent do
  @base_url "https://graph.facebook.com/v22.0/2755161677831837/events?access_token="

  def register_event(
        event_name,
        mobile
      ) do

    mobile = :crypto.hash(:sha256, mobile) |> Base.encode16(case: :lower)
    event_time = DateTime.utc_now() |> DateTime.to_unix()

    json_data = %{
      "data" => [
        %{
          "event_name" => event_name,
          "event_time" => event_time,
          "action_source" => "website",
          "event_source_url" => "https://jobs.ccdcare.com",
          "user_data" => %{
            "ph" => [mobile],
            "client_user_agent" => "Default UA"
          }
        }
      ]
    }

    IO.inspect(json_data, label: "Meta event data")

    headers = %{
      "Content-Type" => "application/json"
    }

    token = System.get_env("META_EVENT_TOKEN")
    end_point_url = "#{@base_url}#{token}"

    IO.inspect(end_point_url, label: "end_point_url")

    case HTTPoison.post(end_point_url, Jason.encode!(json_data), headers,
           timeout: 60_000 * 5,
           recv_timeout: 60_000 * 5
         ) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}}
      when status_code in 200..300 ->
        Jason.decode!(response_body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        IO.puts("Error: Received status code #{status_code}. Response: #{response_body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end
  end
end
