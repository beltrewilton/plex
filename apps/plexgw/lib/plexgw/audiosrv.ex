defmodule AudioSrv.Router do
  use Plug.Router

  import Plug.Conn

  # 1 MB
  @chunk_size 1_048_576
  @valid_token "your_valid_token"


  plug Corsica, origins: "*", allow_credentials: true, allow_methods: :all, allow_headers: :all
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/yoh" do
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  # A plug for token-based authentication
  defp authenticate_token(conn, _opts) do
    # Get the "Authorization" header
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         true <- token == @valid_token do
      # token is valid, proceed
      conn
    else
      _ ->
        # Unauthorized response
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{"error" => "Invalid authentication credentials"}))
        |> halt()
    end
  end

  get "/stream/:filename" do
    # Authenticate token before proceeding with the streaming
    conn = authenticate_token(conn, [])

    # Check if authentication failed (i.e., halted the connection)
    unless conn.halted do
      # Define the path to the audio files
      file_path = Path.join([System.get_env("AUDIO_RECORDING_PATH"), filename])

      # Check if file exists
      if File.exists?(file_path) do
        # Set the response content-type header
        conn
        |> put_resp_content_type("audio/mpeg")
        |> send_chunked(200)
        |> stream_file(file_path)
      else
        # Send 404 response if file does not exist
        send_resp(conn, 404, "File not found")
      end
    end
  end

  # Function to handle file streaming
  defp stream_file(conn, file_path) do
    # Open the file stream
    File.stream!(file_path, [], @chunk_size)
    |> Enum.reduce_while(conn, fn chunk, conn ->
      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, _reason} -> {:halt, conn}
      end
    end)
  end
end
