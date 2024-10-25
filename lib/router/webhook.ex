defmodule Webhook.Router do
  use Plug.Router

  import Plug.Conn

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  post "/" do
    IO.inspect(conn.body_params)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  get "/" do
    IO.inspect("the -get- root of the webhook")
    send_resp(conn, 200, "this is the root [get]")
  end

  forward("/subtask", to: Subtask.Router)

  match _ do
    send_resp(conn, 404, "You are trying something that does not exist.")
  end
end
