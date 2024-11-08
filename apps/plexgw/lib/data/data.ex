defmodule Plexgw.Data do
  import Ecto.Query

  alias Plex.Data.Memory
  alias Plexgw.Repo

  def start_link(_args) do
    Repo.start_link()
  end

  def webhook_log(log \\ %WebHookLog{}) do
    changeset = %WebHookLogSchema{} |> WebHookLogSchema.changeset(Map.from_struct(log))

    case Repo.insert(changeset) do
      {:ok, record} -> {:ok, record}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def cta_log(log \\ %CTALog{}) do
    changeset = %CTALogSchema{} |> CTALogSchema.changeset(Map.from_struct(log))

    case Repo.insert(changeset) do
      {:ok, record} -> {:ok, record}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_webhook_data() do
    # from(w in WebHookLogSchema, where: w.source == "WEBHOOK", limit: ^limit)
    from(w in WebHookLogSchema,
      # where: fragment("response->'entry'->0->>'id' = ?", ^id),
      where:
        not is_nil(fragment("(?)->'entry'->0->'changes'->0->'value'->>'messages'", w.response)),
      where: w.source == "WEBHOOK",
      # order_by: [desc: w.id],
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.all(timeout: 300_000)
  end
end
