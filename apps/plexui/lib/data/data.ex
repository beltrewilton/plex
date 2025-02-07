import Ecto.Query
defmodule Plexui.Data do
  alias Plexui.Repo

  def start_link(_args) do
    Repo.start_link()
  end

  def get_hrapplicant(msisdn, campaign) do
    query = from(a in HrApplicant,
      join: j in HrJob,
      on: a.job_id == j.id,
      where: a.phone_sanitized == ^msisdn and j.va_campaign == ^campaign,
      limit: 1
    )
    Repo.one!(query)
  end
end
