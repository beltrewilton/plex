defmodule Webhook.Router do
  use Plug.Router

  import Plug.Conn

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  plug :dispatch


  post "/" do
    IO.inspect(conn.body_params)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success"}))
  end

  get "/" do
    IO.inspect("the -get- root of the webhook")
    send_resp(conn, 200, "this is the root [get]")
  end

  get "/task" do
    IO.inspect(conn)
    Machinery.Task.start_link([])
    send_resp(conn, 200, "Task initialized, but this call has finished")
  end

  post "/message" do
    {:reply, result} = MachineryOld.entry(:ok, "Some message to machinery")
    some_message_back = "Hei #{inspect(result)}"
    send_resp(conn, 200, Jason.encode!(%{"status" => "success", "message_back" => some_message_back}))
  end

  post "/conversation" do
    {:ok, python} = MachineryOld.init
    {:reply, result} = MachineryOld.generate(python)
    send_resp(conn, 200, Jason.encode!(%{"status" => "success", "time_from_python" => result}))
  end

  post "/llm" do
    resp = MachineryOld.test_venom("Hi there!")
    send_resp(conn, 200, Jason.encode!(resp))
  end

  get "/dummy_set" do
    rdm = to_string(:erlang.ref_to_list(:erlang.make_ref()))
    DummyStatemachine.set_msisdn(rdm)
    send_resp(conn, 200, Jason.encode!(:ok))
  end

  get "/dummy_get" do
    resp = DummyStatemachine.get_msisdn()
    send_resp(conn, 200, Jason.encode!(resp))
  end

  forward "/subtask", to: Subtask.Router

  match _ do
    send_resp(conn, 404, "You are trying something that does not exist.")
  end

end
