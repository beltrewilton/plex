defmodule Goku do
  use GenServer

  defstruct [:simple_test_goku]

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def show_me do
    GenServer.call(__MODULE__, :show_me)
  end

  def reset do
    IO.inspect %__MODULE__{}
    GenServer.cast(__MODULE__, :reset)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :update, 1000)
    {:ok, %{value: 1}}
  end

  @impl true
  def handle_call(:show_me, _from, state) do
    {:reply,  state, state}
  end

  @impl true
  def handle_cast(:reset, _state) do
    {:noreply, %{value: 1}}
  end

  @impl true
  def handle_info(:update, state) do
    IO.puts("Updating #{state.value} ...")
    Process.send_after(self(), :update, 1000)
    {:noreply, Map.put(state, :value, state.value + 1)}
  end

end
