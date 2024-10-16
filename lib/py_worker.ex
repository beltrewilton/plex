# lib/py_worker.ex
defmodule MyApp.PyWorker do
  use GenServer
  use Export.Python
  # optional, omit if adding this to a supervision tree
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def duplicate(text) do
    GenServer.call(__MODULE__, {:duplicate, text})
  end

  # server
  def init(state) do
    # priv_path = Path.join(:code.priv_dir(:my_app), "python")
    {:ok, py} = Python.start_link(python_path: "/Users/beltre.wilton/apps/plex/lib")
    {:ok, Map.put(state, :py, py)}
  end

  def handle_call({:duplicate, text}, _from, %{py: py} = state) do
    IO.inspect(self())
    result = Python.call(py, "dummy", "dummy_func", [text])
    {:reply, result, state}
  end

  def terminate(_reason, %{py: py} = _state) do
    Python.stop(py)
    :ok
  end
end

# alias MyApp.PyWorker
# {_, pid} = PyWorker.start_link([])
# PyWorker.init(%{})
# PyWorker.duplicate("YY")

# Venomous.SnakeArgs.from_params(:dspy_models, :generate, []) |> Venomous.python()
# Map({b'Completed': b'completed', b'In Progress': b'in_progress', b'Scheduled': b'scheduled'}) <class 'erlport.erlterms.Map'>


# {_, pid} = Machinery.init
# Machinery.generate(pid)
