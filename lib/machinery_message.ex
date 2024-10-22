defmodule Machinery.Message do

  @tolerance 0.5 # seconds

  def eta_(s \\ 10),  do: DateTime.utc_now() |> DateTime.add(s, :second)

  def now_, do: DateTime.utc_now()


  def message_deliver(message, whatsapp_id, flow, audio_id, scheduled, forwarded) do
    tasks = %Machinery.State{}.tasks
    if forwarded, do: IO.puts("all logic to forwarded message, including call sync_chat_history")

    message = message_completion(message, flow, scheduled, :talent_entry_form, tasks, audio_id)

    # call sync_chat_history

    # from data.get_latest_message

    # from mnesia: previous_job_id, previous_inactivity_id

    run_date = if flow || audio_id || scheduled, do: nil, else: eta_(@tolerance)

    # call message_firer with run_date

    # call ws client for readed

  end


  def message_firer() do
    now = now_()

    # unreaded_messages logic

    if length([]) > 1 do
      # call sync_chat_history
    end

    # Machinery.entry(message, flow, scheduled, audio_id)

    # send text ws client

    flow_firer(:flow_basic) # dynamic

    # call sync_chat_history

    # remove old JOBS from the scheduler

  end

  def flow_firer(flow_trigger) do
    case flow_trigger do
      :flow_basic -> :send_flow_basic
      :flow_assesment -> :send_flow_assessment
      :flow_scheduler -> :send_flow_scheduler
      _ -> nil # or some default action
    end
  end


  def message_completion(message, flow, scheduled, task, tasks, audio_id) do
    cond do
      flow && scheduled ->
        "Scheduled done"

      flow && Enum.member?(tasks, task) ->
        "#{task} completed."

      audio_id && Enum.member?(tasks, task) ->
        "Voice note for #{task} sent."

      true ->
        message
    end
  end

  def sync_chat_history(msisdn, campaign, message, user_source, whatsapp_id, sending_date) do

  end

  def inactivity_firer do

  end

end
