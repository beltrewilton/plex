defmodule Plex.State do
  @tasks [
    :talent_entry_form,
    :grammar_assessment_form,
    :scripted_text,
    :open_question,
    :end_of_task
  ]

  @optional_tasks [
    :ending_video
  ]

  @app_states [
    :in_progress,
    :scheduled,
    :completed
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
  @user_source "User"
  @ai_scource "AI"
  @tolerance 3_00
  @inactiviry_time 300 * 1_000

  defstruct tasks: @tasks, app_states: @app_states, n_response: @n_response, n_request: @n_request, optional_tasks: @optional_tasks

  require Logger

  alias Plex.Data.Memory
  alias Plex.Data
  alias Plex.Scheduler
  alias WhatsappElixir.Messages
  alias WhatsappElixir.Flow
  alias WhatsappElixir.MediaDl
  alias Util.StaticMessages, as: S

  def get_config() do
    [
      token: System.get_env("CLOUD_API_TOKEN"),
      phone_number_id: System.get_env("CLOUD_API_PHONE_NUMBER_ID"),
      verify_token: System.get_env("CLOUD_API_TOKEN_VERIFY"),
      base_url: "https://graph.facebook.com",
      api_version: "v20.0"
    ]
  end

  def new_n_request(
        utterance,
        current_state,
        previous_state,
        current_task,
        previous_conversation_history
      ) do
    machinery = %__MODULE__{}

    Map.merge(machinery.n_request, %{
      utterance: utterance,
      current_state: current_state,
      previous_state: previous_state,
      current_task: current_task,
      previous_conversation_history: previous_conversation_history
    })
  end

  def new(
        waba_id,
        msisdn,
        message,
        whatsapp_id,
        flow,
        audio_id,
        video_id,
        scheduled,
        forwarded,
        task \\ :talent_entry_form,
        state \\ :in_progress
      ) do
    %ClientState{
      waba_id: waba_id,
      msisdn: msisdn,
      message: message,
      whatsapp_id: whatsapp_id,
      state: state,
      task: task,
      flow: flow,
      audio_id: audio_id,
      video_id: video_id,
      scheduled: scheduled,
      forwarded: forwarded
    }
  end

  defp extract_campaign(%ClientState{} = client) do
    if is_nil(client.task) or client.task == :talent_entry_form do
      case UniqueCodeGenerator.extract_code(client.message) do
        [] ->
          Data.add_applicant_stage(
            client.msisdn,
            @default_campaign,
            client.task,
            client.state
          )

          {:no_replace_message}

        campaign_extracted ->
          campaign_extracted = List.first(campaign_extracted)

          Data.add_applicant_stage(
            client.msisdn,
            campaign_extracted,
            client.task,
            client.state
          )

          # AQUI: fue encontrado `campaign_extracted` entonces remplazar ese mensaje por uno LLM friendly
          {:replace_message, S.random_message(S.user_hello_replaced)}

          #TODO: try to change the default `client.message` variable for a generic one
          # Map.put(client, :message, new_message_from_static)
      end
    end
  end

  defp solve_stage(%ClientState{} = client) do
    case Memory.get_latest_applicant_stage(client.msisdn) do
      {:atomic, []} ->
        case extract_campaign(client) do
          {:replace_message, new_message} -> {Memory.get_latest_applicant_stage(client.msisdn), new_message}

          {:no_replace_message} -> {Memory.get_latest_applicant_stage(client.msisdn), :no_replace_message}
        end

      {:atomic, stage} ->
        client = client_update(client, stage)

        cond do
          not is_nil(client.audio_id) and
              (is_nil(client.task) or client.task == :talent_entry_form) ->
            {:abort}

          true ->
            {{:atomic, stage}, :no_replace_message}
        end
    end
  end

  # old name message_deliver
  def message_handler(
        waba_id,
        msisdn,
        message,
        whatsapp_id,
        flow,
        audio_id,
        video_id,
        scheduled,
        forwarded
      ) do
    client = new(waba_id, msisdn, message, whatsapp_id, flow, audio_id, video_id, scheduled, forwarded)

    message_handler(client, solve_stage(client))
  end

  defp message_handler(%ClientState{} = _client, {{:atomic, stage}, _}) when stage == [] do
    IO.puts("Esto nunca deberia ocurrir,")
  end

  defp message_handler(%ClientState{} = client, {{:atomic, stage}, new_message}) do
    client = client_update(client, stage, new_message)

    Messages.mark_as_read(client.whatsapp_id, get_config())

    IO.inspect(new_message, label: "new_message atom")

    IO.inspect(stage, label: "Stage Object")

    IO.inspect(client, label: "Client Object")

    case client.forwarded do
      false ->
        message =
          process_message(
            client.message,
            client.task,
            client.flow,
            client.scheduled,
            client.audio_id
          )

        Data.add_chat_history(
          client.msisdn,
          client.campaign,
          message,
          @user_source,
          client.whatsapp_id
        )

        Scheduler.kill(
          client.msisdn,
          client.campaign,
          "_message_firer_job"
        )

        Scheduler.kill(
          client.msisdn,
          client.campaign,
          "_inactivity_job"
        )

        run_at =
          if client.flow or not is_nil(client.audio_id) or client.scheduled,
            do: 0,
            else: @tolerance

        Scheduler.delay(
          client.msisdn,
          client.campaign,
          "_message_firer_job",
          fn ->
            message_firer(client)

            Scheduler.kill(
              client.msisdn,
              client.campaign,
              "_message_firer_job"
            )
          end,
          run_at
        )

        Scheduler.delay(
          client.msisdn,
          client.campaign,
          "_inactivity_job",
          fn ->
            inactivity_firer(client)

            Scheduler.kill(
              client.msisdn,
              client.campaign,
              "_inactivity_job"
            )
          end,
          @inactiviry_time
        )

      true ->
        message = S.random_message(S.forwarded_not_allowed)
        Messages.send_message(client.msisdn, message, get_config())

        Data.add_chat_history(
          client.msisdn,
          client.campaign,
          message,
          @user_source,
          client.whatsapp_id
        )
    end

    client = client_update(client)

    {:ok, client}
  end

  defp message_handler(%ClientState{} = _client, {:abort}) do
    IO.puts("Esto nunca deberia ocurrir, enviaron audio asi no mas en lugar del welcome!")
  end

  defp client_update(client, stage, new_message \\ :no_replace_message) do
    if new_message == :no_replace_message do
      Map.merge(client, %{
        campaign: stage.campaign,
        task: stage.task,
        state: stage.state
      })
    else
      Map.merge(client, %{
        campaign: stage.campaign,
        task: stage.task,
        state: stage.state,
        message: new_message
      })
    end
  end

  defp client_update(client) do
    {:atomic, stage} = Memory.get_applicant_stage(client.msisdn, client.campaign)
    client_update(client, stage)
  end

  defp process_message(message, task, flow, schedule, audio_id) do
    cond do
      flow and schedule -> "Scheduled done"
      flow and task == :talent_entry_form -> "Talent entry form completed."
      flow and task == :grammar_assessment_form -> "Grammar assessment form completed."
      not is_nil(audio_id) and task == :scripted_text -> "Voice note for Scripted text sent."
      not is_nil(audio_id) and task == :open_question -> "Voice note for Open question sent."
      true -> message
    end
  end

  # merge : message_firer & entry
  def message_firer(%ClientState{} = client) do
    unreaded_messages = Memory.get_unreaded_messages(client.msisdn, client.campaign)

    unreaded_messages_collected =
      Enum.map(unreaded_messages, fn m -> Enum.at(m, 7) end) |> Enum.join(" ")

    Data.mark_as_readed(client.msisdn, client.campaign)

    cond do
      length(unreaded_messages) == 1 ->
        in_sending_date = List.first(unreaded_messages) |> Enum.at(10)
        Data.mark_as_collected(client.msisdn, client.campaign, in_sending_date)

      length(unreaded_messages) > 1 ->
        Data.add_chat_history(
          client.msisdn,
          client.campaign,
          unreaded_messages_collected,
          @user_source,
          client.whatsapp_id,
          # readed
          true,
          # collected
          true
        )
    end

    if client.flow and not client.scheduled, do: task_completed(client)

    # if switch_to_text, NO debe ejecutar mas nada.
    handle_audio(client)

    handle_video(client)

    client = client_update(client)

    n_request =
      new_n_request(
        unreaded_messages_collected,
        client.state,
        :in_progress,
        client.task,
        chat_history(client.msisdn, client.campaign)
      )

    # TODO: mas pruebas son requeridas LLM...
    n_response = Plex.LLM.generate(n_request)
    IO.inspect(n_response)

    client = client_update(client)

    trigger = flow_trigger(client.task, n_response)

    n_response = process_response(client, n_response)

    IO.inspect(n_response, label: "n_response")

    send_text_message(client.msisdn, n_response.output.response)

    send_flow_message(trigger, client.waba_id, client.msisdn, client.campaign)

    output_llm_booleans = %{
      share_link: n_response.output.share_link,
      schedule: n_response.output.schedule,
      company_question: n_response.output.company_question,
      abort_scheduled_state: n_response.output.abort_scheduled_state
    }

    Data.add_chat_history(
      client.msisdn,
      client.campaign,
      n_response.output.response,
      @ai_scource,
      client.whatsapp_id,
      true,
      true,
      output_llm_booleans
    )

    if n_response.output.schedule do
      # TODO: remove the inactivity clock/job/task
      Scheduler.kill(
        client.msisdn,
        client.campaign,
        "_message_firer_job"
      )
    end

    if n_response.output.abort_scheduled_state do
      # TODO: call the stupid set_state_all function
      #       remove previous_scheduled_job_id
      Scheduler.kill(
        client.msisdn,
        client.campaign,
        "_inactivity_job"
      )
    end

    # {n_response, flow_trigger}
  end

  def inactivity_firer(%ClientState{} = client) do
    message =
    case client.task do
      :talent_entry_form -> S.random_message(S.assignment_reminder)
      :grammar_assessment_form -> S.random_message(S.friendly_reminder)
      :scripted_text -> S.random_message(S.voice_note_reminder_1)
      :open_question -> S.random_message(S.voice_note_2)
      _ -> nil
    end

    if not is_nil(message) do
      {:inactivity}
      Messages.send_message(client.msisdn, message, get_config())
    end
  end

  def send_text_message(msisdn, message, wa_id \\ nil) do
    IO.puts("Here send to WhatsApp client #{msisdn}: #{message}")
    Messages.send_message(msisdn, message, get_config(), wa_id)
    # TODO: hacer log source="REQUEST" del response que genera enviar un mensagge.
    #      la vaina es que los logs son centralizados y esto es un nodo.....
  end


  def send_reaction(msisdn, wa_id) do
    Messages.send_raction_message(msisdn, wa_id, get_config())
  end

  def send_flow_message(:flow_basic, waba_id, msisdn, campaign) do
    IO.puts("flow_basic - #{msisdn}: #{campaign}")

    opts = [
      template_name: System.get_env("TEMPLATE_NAME_FLOW_APPL_BASIC"),
      image_link: System.get_env("TEMPLATE_IMAGE_LINK_FLOW_APPL_BASIC"),
      screen: "APPLICANT_BASIC"
    ]

    data = %{
      "waba_id" => waba_id,
      "msisdn" => msisdn,
      "campaign" => campaign,

      "applicant_basic_header" => System.get_env("APPL_BASIC_HEADER"),
      "applicant_extra_header" => System.get_env("APPL_EXTRA_HEADER"),
      "applicant_extra_two_header" => System.get_env("APPL_EXTRA_TWO_HEADER")
    }

    Flow.send_flow_as_message(msisdn, data, get_config(), opts)
  end

  # def send_flow_message(:flow_basic, waba_id, msisdn, campaign) do
  #   IO.puts("flow_basic - #{msisdn}: #{campaign}")

  #   opts = [
  #     flow_id: System.get_env("FLOW_APPL_BASIC_ID"),
  #     cta: "Click to start",
  #     header: "Your journey starts here",
  #     screen: "APPLICANT_BASIC",
  #     mode: System.get_env("APPLICANT_BASIC_MODE")
  #   ]

  #   data = %{
  #     "waba_id" => waba_id,
  #     "msisdn" => msisdn,
  #     "campaign" => campaign,
  #     "applicant_basic_header" => System.get_env("APPL_BASIC_HEADER"),
  #     "applicant_extra_header" => System.get_env("APPL_EXTRA_HEADER"),
  #     "applicant_extra_two_header" => System.get_env("APPL_EXTRA_TWO_HEADER")
  #   }

  #   Flow.send_flow(msisdn, data, get_config(), opts)
  # end

  def send_flow_message(:flow_assesment, waba_id, msisdn, campaign) do
    IO.puts("flow_assesment - #{msisdn}: #{campaign}")

    opts = [
      template_name: System.get_env("TEMPLATE_NAME_FLOW_ASSESSMENT"),
      image_link: System.get_env("TEMPLATE_IMAGE_LINK_FLOW_ASSESSMENT"),
      screen: "APPLICANT_ASSESSMENT_ONE"
    ]

    questions = S.random_messages(S.applicant_assessment_question)
    q1 = Enum.at(questions, 0)
    q2 = Enum.at(questions, 1)

    data = %{
      "waba_id" => waba_id,
      "msisdn" => msisdn,
      "campaign" => campaign,

      "question_one_error" => false,
      "question_two_error" => false,
      "random_question_one_sentence" => Map.get(q1, "sentence"),
      "random_question_two_sentence" => Map.get(q2, "sentence"),
      "random_question_one_resume" => Map.get(q1, "resume"),
      "random_question_two_resume" => Map.get(q2, "resume")
    }

    Flow.send_flow_as_message(msisdn, data, get_config(), opts)
  end

  def send_flow_message(:flow_scheduler, waba_id, msisdn, campaign) do
    IO.puts("flow_scheduler - #{waba_id} #{msisdn}: #{campaign}")
  end

  def send_flow_message(nil, waba_id, msisdn, campaign) do
    IO.puts("no flow trigger found - #{waba_id} #{msisdn} #{campaign}")
  end

  defp handle_audio(%ClientState{} = client) when not is_nil(client.audio_id) do
    client = client_update(client)

    IO.inspect(client, label: "Client handle Audio")

    send_reaction(client.msisdn, client.whatsapp_id)

    send_text_message(client.msisdn, S.random_message(S.listening), client.whatsapp_id)

    if client.task in [:scripted_text, :open_question] do
      # manage audio with ffmpeg function
      {:ok, audio_file} = MediaDl.get(client.audio_id, client.msisdn, client.campaign, client.waba_id, client.task, :audio)
      {:ok, audio_file} = MediaDl.ogg_to_wav(audio_file)

      if client.task == :scripted_text do
        refText = Memory.get_reftext(client.msisdn, client.campaign, true)

        {:ok, scores} = SpeechSuperClient.request_scripted(
          audio_file,
          %SpeechSuperClient{}.params.para_eval,
          refText
        )

        result = scores["result"]
        warning = result["warning"]

        scripted_score = %SpeechScriptedScore{
          msisdn: client.msisdn,
          campaign:  client.campaign,
          speech_overall: result["overall"],
          speech_refText: refText,
          speech_duration: result["duration"],
          speech_fluency: result["fluency"],
          speech_integrity: result["integrity"],
          speech_pronunciation: result["pronunciation"],
          speech_rhythm: result["rhythm"],
          speech_speed: result["speed"],
          speech_audio_path: "https://audio.synaia.io/stream/#{String.split(audio_file, "/") |> List.last()}",
          speech_warning: warning
        }

        Data.set_score(scripted_score)

        log = %SpeechLog{
          msisdn: client.msisdn,
          campaign:  client.campaign,
          audio_path: audio_file,
          response: scores
        }

        Data.speech_log(log)

      else
        open_question = Memory.get_open_question(client.msisdn, client.campaign, true)

        {:ok, scores} = SpeechSuperClient.request_spontaneous_unscripted(
          audio_file,
          %SpeechSuperClient{}.params.speak_eval_pro,
          open_question,
          %SpeechSuperClient{}.params.ielts_part3
        )

        IO.inspect(scores, label: "request_spontaneous_unscripted")

        result = scores["result"]
        warning = result["warning"]

        un_scripted_score = %SpeechUnScriptedScore{
          msisdn: client.msisdn,
          campaign:  client.campaign,
          speech_open_question: open_question,
          speech_unscripted_overall_score: result["overall"],
          speech_unscripted_length: result["effective_speech_length"],
          speech_unscripted_fluency_coherence: result["fluency_coherence"],
          speech_unscripted_grammar: result["grammar"],
          speech_unscripted_lexical_resource: result["lexical_resource"],
          speech_unscripted_pause_filler: result["pause_filler"],
          speech_unscripted_pronunciation: result["pronunciation"],
          speech_unscripted_relevance: result["relevance"],
          speech_unscripted_speed: result["speed"],
          speech_unscripted_audio_path: "https://audio.synaia.io/stream/#{String.split(audio_file, "/") |> List.last()}",
          speech_unscripted_transcription: result["transcription"],
          speech_unscripted_warning: warning
        }

        Data.set_score(un_scripted_score)

        log = %SpeechLog{
          msisdn: client.msisdn,
          campaign:  client.campaign,
          audio_path: audio_file,
          response: scores
        }

        Data.speech_log(log)

      end


      IO.puts("manage audio with ffmpeg function.")
      task_completed(client)
    else
      switch_to_text = S.random_message(S.switch_to_text)
      # audio only accepted when :scripted_text or :open_question
      Messages.send_message(client.msisdn, switch_to_text, get_config())
      {:switch_to_text}
    end
  end

  defp handle_audio(%ClientState{} = _client) do
    {:no_audio}

    # TODO: esto se supone que detiene el flujo `return en Python` con return response, flow_trigger
  end

  def handle_video(%ClientState{} = client) when not is_nil(client.video_id) do
    client = client_update(client)

    if client.task == :end_of_task do
      {:ok, video_file} = MediaDl.get(client.video_id, client.msisdn, client.campaign, client.waba_id, client.task, :video)

      IO.inspect(video_file, label: "Video is here!")

      send_reaction(client.msisdn, client.whatsapp_id)

      Messages.send_message(client.msisdn, S.random_message(S.video_1), get_config())

      url_video = "https://audio.synaia.io/stream/#{Path.basename(video_file)}"
      Data.update_video_path(client.msisdn, client.campaign, url_video)
    else
      switch_to_text = S.random_message(S.switch_to_text)
      Messages.send_message(client.msisdn, switch_to_text, get_config())
      {:switch_to_text}
    end
  end

  def handle_video(%ClientState{} = _client) do
    {:no_video}
  end


  defp next_task(key) do
    tasks = %__MODULE__{}.tasks
    index = Enum.find_index(tasks, &(&1 == key))

    if index < length(tasks) - 1 do
      Enum.at(tasks, index + 1)
    else
      key
    end
  end

  defp task_completed(%ClientState{} = client) do
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

  defp process_response(%ClientState{} = client, n_response) do
    output = n_response.output

    IO.inspect(client, label: "Client (process_response)")

    new_response =
      cond do
        (client.flow && client.task == :scripted_text && !output.schedule) ||
            String.contains?(output.response, "PLACEHOLDER_1") ->
          refText = Memory.get_reftext(client.msisdn, client.campaign)

          output.response
          |> String.replace("PLACEHOLDER_1", "\n> ❝#{refText}❞\n\n\n_")
          |> String.replace("`", "")

        (client.audio_id && client.task == :open_question && !output.schedule) ||
            String.contains?(output.response, "PLACEHOLDER_2") ->
          open_question = Memory.get_open_question(client.msisdn, client.campaign)

          output.response
          |> String.replace("PLACEHOLDER_2", "\n> ❝#{open_question}❞\n\n\n_")
          |> String.replace("`", "")

        true ->
          output.response
      end

    IO.inspect(new_response, label: "new_response")

    # Map.put(output, :response, new_response)
    # Map.put(n_response, :output, output)
    put_in(n_response[:output][:response], new_response)
  end

  defp chat_history(msisdn, campaign) do
    Memory.get_collected_messages(msisdn, campaign)
    |> Enum.slice(0..-2//1)
    |> Enum.map(fn h -> Enum.at(h, 7) end)
  end
end
