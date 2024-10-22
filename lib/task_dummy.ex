defmodule MyTask do
  use Task

  def start_link(args) do
    Task.start_link(__MODULE__, :run, [args])
  end

  def run(args) do
    Process.sleep(3000)
    IO.puts("[Message from Task]")
    IO.inspect(args)
  end

end
