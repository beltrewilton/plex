defmodule Subtask.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    IO.inspect("Inside subtask.")
    send_resp(conn, 200, "This is a message from subtask")
  end
end
