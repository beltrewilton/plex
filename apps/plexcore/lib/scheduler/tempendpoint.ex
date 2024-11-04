defmodule Scheduler.Tempendpoint do
  use Plug.Router

  import Plug.Conn

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/delayed" do
    # ME QUEDE AQUI....
    name = conn.query_params["name"]
    DelayedExecutor.execute_in_future(fn -> DelayedExecutor.the_function(name) end)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end
end
