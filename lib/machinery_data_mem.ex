defmodule Machinery.Data.Mem do
    alias :mnesia, as: Mnesia

    def start do
        Mnesia.start()
        case Mnesia.create_schema(node()) do
            {:ok, _} -> :ok
            {:error, {:already_exists, _}} -> :ok
            error -> error
        end

        Mnesia.start()
        Mnesia.create_table(Person, [
            attributes: [:id, :value],
            type: :set,
            storage_properties: [ram_copies: [node()]]
        ])

        Mnesia.create_table(ChatHistory, [
            attributes: Machinery.ChatHistory.__schema__(:fields),
            type: :set,
            storage_properties: [ram_copies: [node()]]  
        ])
        Mnesia.add_table_index(ChatHistory, [:msisdn, :campaign, :create_date])

        Mnesia.create_table(ApplicantStage, [
            attributes: Machinery.ApplicantStage.__schema__(:fields),
            type: :set,
            storage_properties: [ram_copies: [node()]]  
        ])
    end

    # chat_history = %Machinery.ChatHistory{msisdn: "18007653427", campaign: "XH000", source: "Github", whatsapp_id: "0009", message: "Hi all",  readed: true, collected: true, sending_date: NaiveDateTime.utc_now(), output_llm_booleans: %{}, create_date: NaiveDateTime.utc_now(), write_date: NaiveDateTime.utc_now()}
    def add_chat_history(%Machinery.ChatHistory{} = chat_history, id) do
        chat_history = Map.drop(chat_history, [:id, :__struct__, :__meta__])
        Mnesia.transaction(fn ->
            Mnesia.write({
                ChatHistory, id,
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

    def add_applicant_stage(%Machinery.ApplicantStage{} = appl_stage, id) do
        appl_stage = Map.drop(appl_stage, [:id, :__struct__, :__meta__])
        Mnesia.transaction(
            fn -> 
                Mnesia.write({
                    ApplicantStage, id, 
                    appl_stage.create_uid,
                    appl_stage.write_uid,
                    appl_stage.msisdn,
                    appl_stage.campaign,
                    appl_stage.task,
                    appl_stage.state,
                    appl_stage.last_update,
                    appl_stage.create_date,
                    appl_stage.write_date
                })
            end
        ) 
    end

    defp filter_message(msisdn, campaign, filter_function) do
        transaction = Mnesia.transaction(fn -> 
            Mnesia.select(
                ChatHistory,
                [
                    {
                        {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$11", :"$12", :"$13", :"$14" },
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
        filter_function = fn messages -> Enum.max_by(
            messages,
            fn [id, _, _, _, _, _, _, _, _, _, _, _, _, _] -> id end
            )
        end
        filter_message(msisdn, campaign, filter_function)
    end

    def get_unreaded_messages(msisdn, campaign) do
        filter_function = fn messages -> Enum.filter(
            messages,
            fn [_, _, _, _, _, _, _, _, readed, _, _, _, _, _] -> readed == false end
            )
        end
        filter_message(msisdn, campaign, filter_function)
        #TODO: mark_as_read & JOB:mark_as_read_db 
    end

    def get_collected_messages(msisdn, campaign) do
        filter_function = fn messages -> Enum.filter(
            messages,
            fn [_, _, _, _, _, _, _, _, _, collected, _, _, _, _] -> collected == true end
            )
        end
        filter_message(msisdn, campaign, filter_function)
    end

    # Machinery.Repo.start_link
    # List.first(Machinery.Repo.all(Machinery.ChatHistory))
    #
    # Machinery.Data.Mem.update_collected("18296456177", "CNVQSOUR84FK", "2024-09-29 11:47:33.406306")

    def update_collected(msisdn, campaign, sending_date) do
        {_, sending_date_iso} = NaiveDateTime.from_iso8601(sending_date)
        # sending_date = DateTime.from_naive!(sending_date, "Etc/UTC")
        # sending_date = DateTime.to_unix(sending_date, :microsecond)
        transaction = Mnesia.transaction(fn -> 
            Mnesia.select(
                ChatHistory,
                [
                    {
                        {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$11", :"$12", :"$13", :"$14" },
                        [{:==, :"$4", msisdn}, {:==, :"$5", campaign}],
                        [:"$$"]
                    }
                ]
            )
        end)
        case transaction do
            {:atomic, []} -> {:error, "No result found with #{msisdn} & #{campaign} & #{inspect(sending_date_iso)}"}
            {:atomic, messages} -> 
                record = Enum.filter(messages, 
                    fn [_, _, _, _, _, _, _, _, _, _, sending_date, _, _, _] -> 
                        sending_date == sending_date_iso
                    end
                )
                record = List.first(record) |> List.to_tuple |> Tuple.insert_at(0, ChatHistory)
                updated_record = put_elem(record, 9, true)
                Mnesia.dirty_write(updated_record)
            error -> {:error, "Unknow error #{inspect(error)}"}
        end
    end








    


    def write_somethin() do
        Mnesia.transaction(fn ->
            Mnesia.write({Person, 1, "Some Value"})
        end)
    end

    def read_something() do
        Mnesia.transaction(fn ->
            Mnesia.read({Person, 1})
        end)
    end
end