defmodule Flow.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    IO.inspect("Inside flow.")
    send_resp(conn, 200, "....This is a message from flow")
  end

end
