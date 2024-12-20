defmodule Integration.Zoho do
  alias Util.Timez, as: T
  @base_url "https://accounts.zoho.eu/oauth/v2/token"
  @candidates_url "https://recruit.zoho.eu/recruit/v2/Candidates"

  def add_candidate(
    last_name,
    first_mame,
    email,
    mobile,
    site,
    cedula,
    type_document_id,
    work_permit,
    english_level,
    availability_towork,
    hear_about_us
  ) do
    email = "#{UUID.uuid1}@xteam.com"

    json_data = %{
      "data" => [
        %{
          "Last_Name" => last_name,
          "First_Name" => first_mame,
          "Email" => email,
          "Mobile" => mobile,
          "Site" => site,
          "Cedula" => cedula,
          "Id_Type" => type_document_id,
          "Work_Permit" => [work_permit],
          "English_Level" => english_level,
          "Modality" => availability_towork,
          "Where_did_you_heard_from_us" => hear_about_us
        }
      ]
    }

    IO.inspect(json_data, label: "Zoho Client")

    token = get_token()

    headers = %{
      "Authorization" => "Zoho-oauthtoken #{token}",
      "Content-Type" => "application/json"
    }

    IO.inspect(headers, label: "Zoho Headers")

    case HTTPoison.post(@candidates_url, Jason.encode!(json_data), headers, timeout: 60_000 * 5, recv_timeout: 60_000 * 5) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} when status_code in 200..300 ->
        Jason.decode!(response_body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        IO.puts("Error: Received status code #{status_code}. Response: #{response_body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end
  end

  defp refresh_token() do
    params = %{
      grant_type: "refresh_token",
      client_id: System.get_env("Z_CLIENT_ID"),
      client_secret: System.get_env("Z_SECRET_CLIENT"),
      refresh_token: System.get_env("Z_REFRESH_TOKEN"),
    }

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    case HTTPoison.post(@base_url, URI.encode_query(params), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to retrieve token. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to retrieve token. Reason: #{reason}"}
    end
  end

  defp get_token() do
    result = Plex.Data.get_access_token()

    case result do
      %Plex.ZohoToken{} = data ->
        if NaiveDateTime.diff(data.expires_at, T.now()) < 0 do # expiro
          {:ok, token} = refresh_token()
          expires_at = T.now(3600, :second)
          Plex.Data.upsert_access_token(Map.get(token, "access_token"), expires_at, data.access_token)

          Map.get(token, "access_token")
        else
          data.access_token
        end

      nil ->
        Plex.Data.upsert_access_token("NONE", T.now(-1, :hour))
        get_token()
    end
  end
end
