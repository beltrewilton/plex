defmodule Plex.Data.Memory do
  alias :mnesia, as: Mnesia

  def start do
    Mnesia.start()

    case Mnesia.create_schema(node()) do
      {:ok, _} -> :ok
      {:error, {:already_exists, _}} -> :ok
      error -> error
    end

    Mnesia.start()

    Mnesia.create_table(Person,
      attributes: [:id, :value],
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )

    Mnesia.create_table(ChatHistory,
      attributes: Plex.ChatHistory.__schema__(:fields),
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )

    Mnesia.add_table_index(ChatHistory, [:msisdn, :campaign, :create_date])

    Mnesia.create_table(ApplicantStage,
      attributes: Plex.ApplicantStage.__schema__(:fields),
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )

    Mnesia.create_table(RefText,
      attributes: [:msisdn_campaign, :text],
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )

    Mnesia.create_table(OpenQuestion,
      attributes: [:msisdn_campaign, :question],
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )

    Mnesia.create_table(Transitivities,
      attributes: [:key, :value],
      type: :set,
      storage_properties: [ram_copies: [node()]]
    )
  end

  # chat_history = %Plex.ChatHistory{msisdn: "18007653427", campaign: "XH000", source: "Github", whatsapp_id: "0009", message: "Hi all",  readed: true, collected: true, sending_date: NaiveDateTime.utc_now(), output_llm_booleans: %{}, create_date: NaiveDateTime.utc_now(), write_date: NaiveDateTime.utc_now()}
  def add_chat_history(%Plex.ChatHistory{} = chat_history, id) do
    chat_history = Map.drop(chat_history, [:id, :__struct__, :__meta__])

    Mnesia.transaction(fn ->
      Mnesia.write({
        ChatHistory,
        id,
        chat_history.create_uid,
        chat_history.write_uid,
        chat_history.msisdn,
        chat_history.campaign,
        chat_history.source,
        chat_history.whatsapp_id,
        chat_history.message,
        chat_history.readed,
        chat_history.collected,
        chat_history.sending_date,
        chat_history.output_llm_booleans,
        chat_history.create_date,
        chat_history.write_date
      })
    end)
  end

  def get_applicant_stage(msisdn, campaign) do
    result =
      Mnesia.transaction(fn ->
        Mnesia.select(
          ApplicantStage,
          [
            {
              {ApplicantStage, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9",
               :"$10"},
              [{:==, :"$4", msisdn}, {:==, :"$5", campaign}],
              [:"$$"]
            }
          ]
        )
      end)

    case result do
      {:atomic, stage} ->
        {
          :atomic,
          Enum.map(stage, &ApplicantStageStruct.from_record/1) |> List.first()
        }

      error ->
        IO.inspect(error)
    end
  end

  # set_state in Python
  def add_applicant_stage(%Plex.ApplicantStage{} = appl_stage, id) do
    appl_stage = Map.drop(appl_stage, [:id, :__struct__, :__meta__])
    # IO.inspect(appl_stage.task, label: "Task: ")
    # IO.inspect(appl_stage.state, label: "State: ")
    task =
      if is_binary(appl_stage.task), do: String.to_atom(appl_stage.task), else: appl_stage.task

    state =
      if is_binary(appl_stage.state), do: String.to_atom(appl_stage.state), else: appl_stage.state

    Mnesia.transaction(fn ->
      Mnesia.write({
        ApplicantStage,
        id,
        appl_stage.create_uid,
        appl_stage.write_uid,
        appl_stage.msisdn,
        appl_stage.campaign,
        task,
        state,
        appl_stage.last_update,
        appl_stage.create_date,
        appl_stage.write_date
      })
    end)
  end

  defp filter_message(msisdn, campaign, filter_function) do
    transaction =
      Mnesia.transaction(fn ->
        Mnesia.select(
          ChatHistory,
          [
            {
              {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10",
               :"$11", :"$12", :"$13", :"$14"},
              [{:==, :"$4", msisdn}, {:==, :"$5", campaign}],
              [:"$$"]
            }
          ]
        )
      end)

    case transaction do
      {:atomic, []} -> {:error, "No result found with #{msisdn} & #{campaign}"}
      {:atomic, messages} -> filter_function.(messages)
      _ -> {:error, "Unknow error"}
    end
  end

  def get_latest_message(msisdn, campaign) do
    filter_function = fn messages ->
      Enum.max_by(
        messages,
        fn [id, _, _, _, _, _, _, _, _, _, _, _, _, _] -> id end
      )
    end

    filter_message(msisdn, campaign, filter_function)
  end

  def get_unreaded_messages(msisdn, campaign) do
    filter_function = fn messages ->
      Enum.filter(
        messages,
        fn [_, _, _, _, _, _, _, _, readed, _, _, _, _, _] -> readed == false end
      )
    end

    # Plex.Data.Memory.get_unreaded_messages("18092231016", "CNVQSOUR84FK")

    unreaded_messages = filter_message(msisdn, campaign, filter_function)
    # unreaded_messages = [Enum.at(unreaded_messages, 0)] # ~ debug

    unreaded_messages
  end

  def get_collected_messages(msisdn, campaign) do
    filter_function = fn messages ->
      Enum.filter(
        messages,
        fn [_, _, _, _, _, _, _, _, _, collected, _, _, _, _] -> collected == true end
      )
    end

    filter_message(msisdn, campaign, filter_function)
  end

  def select_all(msisdn, campaign) do
    Mnesia.transaction(fn ->
      Mnesia.select(
        ChatHistory,
        [
          {
            {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10",
             :"$11", :"$12", :"$13", :"$14"},
             [{:==, :"$4", msisdn}, {:==, :"$5", campaign}],
            [:"$$"]
          }
        ]
      )
    end)
  end

  # {_, result} = Plex.Data.Mem.select_all
  #
  # Plex.Repo.start_link
  # List.first(Plex.Repo.all(Plex.ChatHistory))
  #
  # Plex.Data.Mem.update_collected("18296456177", "CNVQSOUR84FK", "2024-09-29 11:47:33.406306")

  def update_collected(msisdn, campaign, in_sending_date) do
    # {_, sending_date_iso} = NaiveDateTime.from_iso8601(sending_date)
    # sending_date = DateTime.from_naive!(sending_date, "Etc/UTC")
    # sending_date = DateTime.to_unix(sending_date, :microsecond)
    transaction =
      Mnesia.transaction(fn ->
        Mnesia.select(
          ChatHistory,
          [
            {
              {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10",
               :"$11", :"$12", :"$13", :"$14"},
              [{:==, :"$4", msisdn}, {:==, :"$5", campaign}],
              [:"$$"]
            }
          ]
        )
      end)

    case transaction do
      {:atomic, []} ->
        {:error, "No result found with #{msisdn} & #{campaign} & #{inspect(in_sending_date)}"}

      {:atomic, messages} ->
        record =
          Enum.filter(
            messages,
            fn [_, _, _, _, _, _, _, _, _, _, sending_date, _, _, _] ->
              sending_date == in_sending_date
            end
          )

          IO.inspect(in_sending_date)
          IO.inspect(record)

        List.first(record)
        |> List.to_tuple()
        |> Tuple.insert_at(0, ChatHistory)
        |> put_elem(9, true)
        |> Mnesia.dirty_write()

      error ->
        {:error, "Unknow error #{inspect(error)}"}
    end
  end

  def mark_as_readed(msisdn, campaign) do
    filter_function = fn messages ->
      Enum.each(
        messages,
        fn message ->
          List.replace_at(message, 9, true)
          |> List.to_tuple()
          |> Tuple.insert_at(0, ChatHistory)
          |> Mnesia.dirty_write()
        end
      )
    end

    filter_message(msisdn, campaign, filter_function)
  end

  def get_latest_applicant_stage(msisdn, min_days \\ 30) do
    filter_function = fn stages ->
      Enum.filter(
        stages,
        fn [_, _, _, _, _, _, _, last_update, _, _] ->
          Date.diff(NaiveDateTime.utc_now(), last_update) < min_days
        end
      )
      |> case do
        [] -> []
        result -> Enum.max_by(result, fn [id, _, _, _, _, _, _, _, _, _] -> id end)
      end
    end

    result =
      Mnesia.transaction(fn ->
        Mnesia.select(
          ApplicantStage,
          [
            {
              {ApplicantStage, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9",
               :"$10"},
              [{:==, :"$4", msisdn}],
              [:"$$"]
            }
          ]
        )
      end)

    case result do
      {:atomic, []} ->
        {:atomic, []}

      {:atomic, stage} ->
        case filter_function.(stage) do
          [] ->
            {:atomic, []}

          stage ->
            stage = ApplicantStageStruct.from_record(stage)
            {:atomic, stage}
        end

      error ->
        {:error, "Unknow error #{inspect(error)}"}
    end
  end

  def add_reftext(msisdn, campaign, text) do
    msisdn_campaign = msisdn <> campaign

    Mnesia.transaction(fn ->
      Mnesia.write({RefText, msisdn_campaign, text})
    end)
  end

  def get_reftext(msisdn, campaign) do
    msisdn_campaign = msisdn <> campaign

    Mnesia.transaction(fn ->
      Mnesia.match_object({RefText, msisdn_campaign, :_})
    end)
  end

  def add_open_question(msisdn, campaign, question) do
    msisdn_campaign = msisdn <> campaign

    Mnesia.transaction(fn ->
      Mnesia.write({OpenQuestion, msisdn_campaign, question})
    end)
  end

  def get_open_question(msisdn, campaign) do
    msisdn_campaign = msisdn <> campaign

    Mnesia.transaction(fn ->
      Mnesia.match_object({OpenQuestion, msisdn_campaign, :_})
    end)
  end

  def transitivity_set(param, msisdn, campaign, value) do
    key = param <> msisdn <> campaign

    Mnesia.transaction(fn ->
      Mnesia.write({Transitivities, key, value})
    end)
  end
end
