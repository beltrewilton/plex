defmodule Plex.Scheduler do
  alias Plex.Data.Memory
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def schedule(msisdn, campaign, task_name, funk, delay_ms \\ 10_000) do
    # Send a message after `delay_ms` milliseconds
    ref_process = Process.send_after(__MODULE__, {:execute, funk}, delay_ms)

    ref_string =
      inspect(ref_process)
      |> String.replace("#Reference<", "")
      |> String.slice(0..-2//1)

    Memory.add_ref(msisdn, campaign, task_name, ref_string, ref_process)
  end

  # Plex.Scheduler.schedule("18296456177", "BLACKOUT", "some_task_name", fn -> Plex.Scheduler.dummy("Wilton") end) # TODO: also call cancel_execution
  # Plex.Scheduler.calcel_execution("18296456177", "BLACKOUT", "some_task_name")
  # Plex.Data.Memory.get_ref("18296456177", "BLACKOUT", "some_task_name")

  # ref_process = ref(ref_process)
  # remaining_time = Process.cancel_timer(ref_process)
  # remaining_time / 1_000

  def calcel_execution(msisdn, campaign, task_name) do
    case Memory.get_ref(msisdn, campaign, task_name) do
      {_, [{_, _, _, process_ref}]} ->
        remaining_time = Process.cancel_timer(process_ref)
        Memory.remove_ref(msisdn, campaign, task_name)
        if remaining_time, do: remaining_time / 1_000, else: 0

      {:atomic, []} ->
        Memory.remove_ref(msisdn, campaign, task_name)
        0

      _ -> 0
    end
  end

  def dummy(name) do
    IO.puts("Hello => #{name}")
  end

  # Server (GenServer) callbacks

  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:execute, funk}, state) do
    # Call the function passed to schedule/2
    funk.()
    {:noreply, state}
  end
end
