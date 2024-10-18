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

    def get_latest_chat(msisdn, campaign) do
        Mnesia.transaction(fn -> 
            Mnesia.select(
                ChatHistory,
                [
                    {
                        {ChatHistory, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$11", :"$12", :"$13", :"$14" },
                        [{:==, :"$4", msisdn}],
                        [:"$$"]
                    }
                ]
            )
            |> Enum.max_by(fn [id, _, _, _, _, _, _, _, _, _, _, _, _, _] -> id end)
        end)
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