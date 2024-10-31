defmodule Plexgw.Setup do
  alias :mnesia, as: Mnesia

  def start do
    Mnesia.start()

    case Mnesia.create_schema(node()) do
      {:ok, _} -> :ok
      {:error, {:already_exists, _}} -> :ok
      error -> error
    end

    Mnesia.start()

    Mnesia.create_table(PlexConfig,
      attributes: [:waba_id, :target_node, :app_type],
      type: :ordered_set,
      storage_properties: [ram_copies: [node()]]
    )

    setup()
  end

  def setup do
    add("442392808948818", :"plexcore1@10.0.0.28", :plex_app)
  end

  def get(waba_id) do
    transaction =
      Mnesia.transaction(fn ->
        Mnesia.select(
          PlexConfig,
          [
            {
              {PlexConfig, :"$1", :"$2", :"$3"},
              [{:==, :"$1", waba_id}],
              [:"$$"]
            }
          ]
        )
      end)

    case transaction do
      {:atomic, []} -> [waba_id, nil, nil]

      {:atomic, config} -> config |> List.first()

      _ -> [waba_id, nil, nil]
    end
  end

  def add(waba_id, target_node, app_type) do
    Mnesia.transaction(fn ->
      Mnesia.write({
        PlexConfig,
        waba_id,
        target_node,
        app_type
      })
    end)
  end
end
