defmodule Machinery.State do
  @tasks %{
    talent_entry_form: 1,
    grammar_assessment_form: 2,
    scripted_text: 3,
    open_question: 4,
    end_of_task: 5
  }

  @app_states [
    :in_progress, :scheduled, :completed
  ]

  @n_response %{
    output: %{
      response: "random text",
      share_link: true,
      schedule: false,
      company_question: false,
      abort_scheduled_state: false
    }
  }

  @n_request %{
    utterance: <<>>,
    app_states: @app_states,
    tasks: @tasks,
    current_state: nil,
    previous_state: nil,
    current_task: nil,
    previous_conversation_history: []
  }

  @default_campaign "CNDEFAULT"

  defstruct tasks: @tasks, app_states: @app_states, n_response: @n_response, n_request: @n_request

  require Logger

  alias Machinery.Data.Mem
  alias Machinery.Data


  defp new_n_request(utterance, current_state, previous_state, current_task, previous_conversation_history) do
    machinery = %__MODULE__{}
    n_request = machinery.n_request
    |> Map.put(:utterance, utterance)
    |> Map.put(:current_state, current_state)
    |> Map.put(:previous_state, previous_state)
    |> Map.put(:current_task, current_task)
    |> Map.put(:previous_conversation_history, previous_conversation_history)
    n_request
  end

  def new(msisdn, message, whatsapp_id, flow, audio_id, scheduled, forwarded, task \\ "Talent Entry Form", state \\ "In Progress") do
    %ClientState{
      msisdn: msisdn,
      message: message,
      whatsapp_id: whatsapp_id,
      state: state,
      task: task,
      flow: flow,
      audio_id: audio_id,
      scheduled: scheduled,
      forwarded: forwarded
    }
  end

  def extract_campaign(%ClientState{} = client) do
    if is_nil(client.audio_id) do
      if is_nil(client.task) or client.task == "Talent Entry Form" do
        case UniqueCodeGenerator.extract_code(client.message) do
          [] ->
            Data.add_applicant_stage(
              client.msisdn,
              @default_campaign,
              client.task,
              client.state
            )

          campaign_extracted ->
            campaign_extracted = List.first(campaign_extracted)
            Data.add_applicant_stage(
              client.msisdn,
              campaign_extracted,
              client.task,
              client.state
            )
            # try to change the default `client.message` variable for a generic one
            # Map.put(client, :message, new_message_from_static)
        end
      end
    end

    if not is_nil(client.audio_id) and is_nil(client.task) or client.task == "Talent Entry Form" do
      #TODO:
      #     si lo primero que tenemos es un audio, se debe abortar, la app no esta preparada, no
      #     no tiene la campaign aun.
      {:abort}
    else
      #TODO: here get the last campaign no importa que sea la reciente o una anterior
      # debe ser ''''the last'''''
      Mem.get_latest_campaign(client.msisdn)
    end
  end

  # old name message_deliver
  def message_handler(%ClientState{} = client) do
    message_firer(client)
  end

  # merge : message_firer & entry
  defp message_firer(%ClientState{} = client) do
    # case extract_campaign(client) do
    #   {}
    # end

    stage = Data.get_stage(client.msisdn, client.campaign)

    case client.forwarded do
      false ->
        if client.flow and not client.scheduled, do: task_completed("form_completed")

        handle_audio(:scripted_text, client.audio_id)

        n_request = new_n_request(client.message, :in_progress, :in_progress, :talent_entry_form, [])
        n_response = Machinery.Llm.generate(n_request)
        flow_trigger = flow_trigger(:talent_entry_form, n_response)
        n_response = process_response(:talent_entry_form, true, false, "123", n_response)

        {n_response, flow_trigger}

      true -> {:ignore, "send wa message avoiding forwarder"}
    end
  end


  defp handle_audio(task_name, audio_id) when not is_nil(audio_id) do
    machinery = struct(__MODULE__)
    # IO.inspect machinery
    case Map.get(machinery.tasks, task_name) do
     3 -> task_completed("#3")
     4 -> task_completed("#4")
     _ ->
      response = machinery.n_response
      {response, _flow_trigger = nil}
    end
  end

  defp handle_audio(task_name, _)  do
    {:no_audio}
  end


  defp task_completed(message), do: IO.puts("task completed #{message}")


  defp flow_trigger(task_name, n_response) do
    machinery = struct(__MODULE__)
    cond do
      n_response.share_link and 1 == Map.get(machinery.tasks, task_name) -> :flow_basic
      n_response.share_link and 2 == Map.get(machinery.tasks, task_name) -> :flow_assesment
      n_response.schedule and task_name in Enum.slice(machinery.tasks, 0..-2) -> :flow_scheduler
      true -> nil
    end
  end


  defp process_response(task, flow, scheduled, audio_id, n_response) do
    machinery = struct(__MODULE__)
    if (flow && task == Map.get(machinery.tasks, 3) && !scheduled) || String.contains?(n_response.response, "PLACEHOLDER_1") do
      ref_text = "random_message"
      n_response.response
      |> String.replace("PLACEHOLDER_1", "\n> ❝#{ref_text}❞\n\n\n_")
      |> String.replace("`", "")
    else
      n_response.response
    end

    if (audio_id && task == Map.get(machinery.tasks, 4) && !scheduled) || String.contains?(n_response.response, "PLACEHOLDER_2") do
      question_1 = "random_message"
      n_response.response
      |> String.replace("PLACEHOLDER_2", "\n> ❝#{question_1}❞\n\n\n_")
      |> String.replace("`", "")
    else
      n_response.response
    end

    n_response
  end

end
