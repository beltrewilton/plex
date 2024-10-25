defmodule Plex.State do
  @tasks [
    :talent_entry_form,
    :grammar_assessment_form,
    :scripted_text,
    :open_question,
    :end_of_task
  ]

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
    },
    previous_conversation_history: []
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

  alias Plex.Data.Memory
  alias Plex.Data

  def new_n_request(utterance, current_state, previous_state, current_task, previous_conversation_history) do
    machinery = %__MODULE__{}
    Map.merge(machinery.n_request, %{
      utterance: utterance,
      current_state: current_state,
      previous_state: previous_state,
      current_task: current_task,
      previous_conversation_history: previous_conversation_history
    })
  end

  def new(msisdn, message, whatsapp_id, flow, audio_id, scheduled, forwarded, task \\ :talent_entry_form, state \\ :in_progress) do
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
    if is_nil(client.task) or client.task == :talent_entry_form do
      case UniqueCodeGenerator.extract_code(client.message) do
        [] ->
          Data.add_applicant_stage(
            client.msisdn,
            @default_campaign,
            client.task,
            client.state
          )

        campaign_extracted ->
          IO.inspect(client.task, label: "client.task: ")
          IO.inspect(client.state, label: "client.state: ")
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

  def solve_stage(%ClientState{} = client) do
    cond do
      is_nil(client.audio_id) ->
        case Memory.get_latest_applicant_stage(client.msisdn) do # return ApplicantStageStruct
          {:atomic, []} ->
            extract_campaign(client)
            Memory.get_latest_applicant_stage(client.msisdn)

          {:atomic, stage} -> {:atomic, stage}
        end

      not is_nil(client.audio_id) and (is_nil(client.task) or client.task == :talent_entry_form) ->
        {:abort}
    end
    # if is_nil(client.audio_id) do

    # end

    # if not is_nil(client.audio_id) and (is_nil(client.task) or client.task == :talent_entry_form) do
    #   #TODO:
    #   #     si lo primero que tenemos es un audio, se debe abortar, la app no esta preparada, no
    #   #     no tiene la campaign aun.
    #   {:abort}
    # end
  end

  # old name message_deliver
  def message_handler(%ClientState{} = client) do
  # Plex.Repo.start_link
  # client = Plex.State.new("18092231016", "Hi, this is my promo code CNVQSOUR84FK, I'm interested 💚!", "wa", false, nil, false, false)
  # {:ok, client} = Plex.State.message_handler(client)
  # ----- {:atomic, stage} = Plex.State.solve_stage(client)
  # Plex.Data.register_or_update(client.msisdn, "Delta Magui", 1, true, "yes", "yes", "Bonao", client.campaign)
  # client = Plex.State.new(client.msisdn, "Okay, completed", "wa", true, nil, false, false)
  # # {:ok, client} = Plex.State.message_handler(client)
  #------  {:atomic, stage} = Plex.State.solve_stage(client)

  # Plex.Data.Memory.get_applicant_stage("18092231010", "CNVQSOUR84FK")



  # Plex.Data.update_hrapplicant(client.msisdn, stage.campaign, task)
  # Plex.Data.update_applicant_stage(client.msisdn, stage.campaign, task, stage.state)
  #

  #  Plex.State.extract_campaign(client)
    message_handler(client, solve_stage(client)) # return ApplicantStageStruct
  end

  defp client_update(client, stage) do
    Map.merge(client, %{
      campaign: stage.campaign,
      task: stage.task,
      state: stage.state
    })
  end

  defp client_update(client) do
    {:atomic, stage} = Memory.get_applicant_stage(client.msisdn, client.campaign)
    client_update(client, stage)
  end

  defp message_handler(%ClientState{} = _client, {:atomic, stage}) when stage == [] do
    IO.puts("Esto nunca deberia ocurrir,")
  end

  defp message_handler(%ClientState{} = client, {:atomic, stage}) do
    IO.inspect(stage)
    client = client_update(client, stage)
    IO.inspect(client)

    message_firer(client)

    client = client_update(client)

    {:ok, client}
  end

  defp message_handler(%ClientState{} = _client, {:abort}) do
    IO.puts("Esto nunca deberia ocurrir, enviaron audio asi no mas en lugar del welcome!")
  end

  # merge : message_firer & entry
  def message_firer(%ClientState{} = client) do
    case client.forwarded do
      false ->
        if client.flow and not client.scheduled, do: task_completed(client)

        handle_audio(client)

        client = client_update(client) # TODO: register witout name !!
        n_request = new_n_request(client.message, client.state, :in_progress, client.task, []) # TODO: read chat history from mem
        n_response = Plex.Llm.generate(n_request) #TODO: mas pruebas son requeridas LLM...
        IO.inspect(n_response)

        trigger = flow_trigger(client.task, n_response)

        n_response = process_response(n_response, client.task, client.flow, client.audio_id)

        send_text_message(client.msisdn, n_response.output.response)

        send_flow_message(trigger, client.msisdn, client.campaign)

        Data.add_chat_history(
          client.msisdn,
          client.campaign,
          n_response.output.response,
          "AI",
          client.whatsapp_id
        )

        if n_response.output.schedule do
          # TODO: remove the inactivity clock/job/task
        end

        if n_response.output.abort_scheduled_state do
          # TODO: call the stupid set_state_all function
          #       remove previous_scheduled_job_id
        end


        # {n_response, flow_trigger}

      true -> {:ignore, "send wa message avoiding forwarder"}
    end
  end

  def send_text_message(msisdn, message) do
    IO.puts("Here send to WhatsApp client #{msisdn}: #{message}")
  end

  def send_flow_message(:flow_basic, msisdn, campaign) do
    IO.puts("flow_basic - #{msisdn}: #{campaign}")
  end

  def send_flow_message(:flow_assesment, msisdn, campaign) do
    IO.puts("flow_assesment - #{msisdn}: #{campaign}")
  end

  def send_flow_message(:flow_scheduler, msisdn, campaign) do
    IO.puts("flow_scheduler - #{msisdn}: #{campaign}")
  end

  def send_flow_message(nil, msisdn, campaign) do
    IO.puts("no flow trigger found - #{msisdn}: #{campaign}")
  end

  defp handle_audio(%ClientState{} = client) when not is_nil(client.audio_id) do
    client = client_update(client)
    if client.task in [:scripted_text, :open_question] do
      # manage audio with ffmpeg function
      IO.puts("manage audio with ffmpeg function.")
      task_completed(client)
    else
      # random_message(switch_to_text)
      {:switch_to_text} # audio only accepted when :scripted_text or :open_question
    end
  end

  defp handle_audio(%ClientState{} = _client)  do
    {:no_audio}
    #TODO: esto se supone que detiene el flujo `return en Python` con return response, flow_trigger
  end


  def next_task(key) do
    tasks = %__MODULE__{}.tasks
    index = Enum.find_index(tasks, &(&1 == key))
    if index < length(tasks) - 1 do
      Enum.at(tasks, index + 1)
    else
      key
    end
  end

  def task_completed(%ClientState{} = client) do
    client = Map.put(client, :task, next_task(client.task))

    client = if client.task == :end_of_task, do: Map.put(client, :state, :completed), else: client

    Data.update_hrapplicant(client.msisdn, client.campaign, client.task)

    Data.update_applicant_stage(client.msisdn, client.campaign, client.task, client.state)

    {:ok, client}
  end


  defp flow_trigger(task, n_response) do
    machinery = struct(__MODULE__)
    cond do
      n_response.output.share_link and :talent_entry_form == task -> :flow_basic

      n_response.output.share_link and :grammar_assessment_form == task -> :flow_assesment

      n_response.output.schedule and task in Enum.drop(machinery.tasks, -1) -> :flow_scheduler

      true -> nil
    end
  end


  def process_response(n_response, task, flow, audio_id) do
    output = n_response.output
    new_response =
    cond do
      (flow && task == :scripted_text && !output.scheduled) || String.contains?(output.response, "PLACEHOLDER_1") ->
        ref_text = "random_message"
          output.response
          |> String.replace("PLACEHOLDER_1", "\n> ❝#{ref_text}❞\n\n\n_")
          |> String.replace("`", "")


      (audio_id && task == :open_question && !output.scheduled) || String.contains?(output.response, "PLACEHOLDER_2") ->
        question_1 = "random_message"
          output.response
          |> String.replace("PLACEHOLDER_2", "\n> ❝#{question_1}❞\n\n\n_")
          |> String.replace("`", "")

      true -> output.response
    end

    Map.put(output, :response, new_response)
    Map.put(n_response, :output, output)
  end

end
