defmodule Util.Addnode do
  def start(gateway_node, target_node, waba_id, type_app \\ :plex_app) do
    Node.connect(gateway_node) # :"plexgw@10.0.0.28"
    :mnesia.stop()
    :mnesia.start()
    :mnesia.change_config(:extra_db_nodes, [gateway_node])
    :mnesia.transaction(fn -> :mnesia.write({PlexConfig, waba_id, target_node, type_app}) end)
  end
end
