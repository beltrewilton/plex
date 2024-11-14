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
    # add("442392808948818", :"ccd@10.0.0.28", :plex_app)
    add("442392808948818", :"ccd@10.132.102.216", :plex_app)
  end

  # Util.Addnode.start(:"plexgw@10.0.0.28", :"synaia@10.0.0.28", "367131756473430")
  # Util.Addnode.start(:"plexgw@10.0.0.28", :"ceidi@10.0.0.28", "443834038808808")

  # TODO: THE RECIPE FOR NODES
  # start debug plexgw: bya launch -> iex --name plexgw@10.0.0.28 -S mix
  #
  # start console iex --name plexcore1@10.0.0.28 -S mix
  # connect Node.connect(:"plexgw@10.0.0.28")
  # MNESIA CONNECT
  # .  :mnesia.stop()
  #   :mnesia.start()
  #   :mnesia.change_config(:extra_db_nodes, [:"plexgw@10.0.0.28"])
  # READ
  #  :mnesia.transaction(fn -> :mnesia.read({PlexConfig, "442392808948818"}) end)
  # WRITE
  # :mnesia.transaction(fn -> :mnesia.write({PlexConfig, "367131756473430", :"plexcore2@10.0.0.28", :plex_app}) end)
  # READ
  #  :mnesia.transaction(fn -> :mnesia.read({PlexConfig, "367131756473430"}) end)
  # see console for 367131756473430 log
  # READ ALL
  # :mnesia.transaction(fn ->  :mnesia.match_object({PlexConfig, :_, :_, :_}) end)

  # Util.Addnode.start(:"plexgw@10.0.0.28", :"plexcore2@10.0.0.28", "442392808948818")

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
