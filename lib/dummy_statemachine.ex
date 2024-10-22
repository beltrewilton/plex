defmodule DummyStatemachine do
  use GenServer

  @me __MODULE__

  def start_link(_args) do
    GenServer.start_link(@me, %{}, [name: @me])
  end

  def init(msisdn) do
    {:ok, %{msisdn: msisdn, data: %{} }}
  end

  def set_msisdn(value) do
    # IO.puts("Client process:")
    # IO.inspect(self())
    GenServer.cast(@me, {:set_msisdn, :msisdn, value})
  end

  def get_msisdn do
    GenServer.call(@me, :get_msisdn)
  end

  def handle_cast({:set_msisdn, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call(:get_msisdn, from, state) do
    # IO.puts("Server process:")
    # IO.inspect(self())
    # IO.inspect(from)
    # IO.puts("\n")
    {:reply, state, state}
  end
end
