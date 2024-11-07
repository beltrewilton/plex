defmodule Plex.Scheduler do
  alias Plex.Data
  alias Plex.Data.Memory
  alias WhatsappElixir.Messages
  alias Util.Timez, as: T

  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def delay(msisdn, campaign, task_name, funk, delay_ms \\ 10_000) do
    # Send a message after `delay_ms` milliseconds
    ref_process = Process.send_after(__MODULE__, {:execute, funk}, delay_ms)

    ref_string =
      inspect(ref_process)
      |> String.replace("#Reference<", "")
      |> String.slice(0..-2//1)

    Memory.add_ref(msisdn, campaign, task_name, ref_string, ref_process)
  end

  # Plex.Scheduler.delay("18296456177", "BLACKOUT", "some_task_name", fn -> Plex.Scheduler.dummy("Wilton") end) # TODO: also call cancel_execution
  # Plex.Scheduler.kill("18296456177", "BLACKOUT", "some_task_name")
  # Plex.Data.Memory.get_ref("18296456177", "BLACKOUT", "some_task_name")

  # ref_process = ref(ref_process)
  # remaining_time = Process.cancel_timer(ref_process)
  # remaining_time / 1_000

  def kill(msisdn, campaign, task_name) do
    case Memory.get_ref(msisdn, campaign, task_name) do
      {_, [{_, _, _, process_ref}]} ->
        remaining_time = Process.cancel_timer(process_ref)
        Memory.remove_ref(msisdn, campaign, task_name)
        if remaining_time, do: remaining_time / 1_000, else: 0

      {:atomic, []} ->
        Memory.remove_ref(msisdn, campaign, task_name)
        0

      _ ->
        0
    end
  end

  def queue(msisdn, campaign, scheduled_date, recover \\ false) do
    if recover == false do
      Data.applicant_scheduler(msisdn, campaign, scheduled_date)
    end

    delay_ms = NaiveDateTime.diff(scheduled_date, T.now()) * 1_000

    Process.send_after(
      __MODULE__,
      {
        :queue,
        fn ->
          IO.puts("WELCOME BACK??? A beauty WhatsApp message ....")

          # Messages.send_message(msisdn, "A beauty WhatsApp message ....", Plex.State.get_config())
          # TODO: or generate a LLM message according to history.

          Data.done_scheduler(msisdn, campaign)
        end
      },
      delay_ms
    )
  end

  # Server (GenServer) callbacks

  @impl true
  def init(state) do
    # {:ok, state}
    {:ok, state, {:continue, :rescheduler}}
  end

  @impl true
  def handle_info({:execute, funk}, state) do
    # Call the function passed to schedule/2
    funk.()
    {:noreply, state}
  end

  @impl true
  def handle_info({:queue, funk}, state) do
    # Call the function passed to schedule/2
    funk.()
    {:noreply, state}
  end

  @impl true
  def handle_continue(:rescheduler, state) do
    restore_schedules()
    {:noreply, state}
  end

  defp restore_schedules() do
    IO.puts("Restoring schedules ...")

    scheds = Data.get_scheduled_applicants()

    Enum.each(
      scheds,
      fn s ->
        queue(s.msisdn, s.campaign, s.scheduled_date, true)
      end
    )
  end
end
