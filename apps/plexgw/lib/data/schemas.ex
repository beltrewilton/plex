defmodule WebHookLogSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "va_webhook_log" do
    field(:source, :string)
    field(:response, :map)
    field(:waba_id, :string)
    field(:received_at, :naive_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :source,
      :response,
      :waba_id,
      :received_at
    ])
    |> put_change(:received_at, NaiveDateTime.utc_now())
    |> validate_required([
      :source
    ])
  end
end

defmodule CTALogSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "va_cta_log" do
    field(:referer, :string)
    field(:user_agent, :string)
    field(:campaign, :string)
    field(:waba_id, :string)
    field(:received_at, :naive_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :referer,
      :user_agent,
      :campaign,
      :waba_id,
      :received_at
    ])
    |> put_change(:received_at, NaiveDateTime.utc_now())
    |> validate_required([
      :referer,
      :user_agent,
      :campaign
    ])
  end
end
