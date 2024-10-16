defmodule Machinery.Task do
  use Task

  def start_link(_arg) do
    Task.start_link(&sample_task/0)
  end

  def sample_task() do
    task = self()
    IO.inspect(task)
    t = :rand.uniform(3)
    IO.puts("Simulating #{t} seconds of running ..")
    Process.sleep(t*1000)
    IO.puts("Work done!")
  end

end
