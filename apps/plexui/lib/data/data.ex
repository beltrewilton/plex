import Ecto.Query
defmodule Plexui.Data do
  alias Plex.ChatHistory
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
    applicant = Repo.one!(query)

    scores_with_labels = [
      {"A1", applicant.a1_score},
      {"A2", applicant.a2_score},
      {"B1", applicant.b1_score},
      {"B2", applicant.b2_score},
      {"C1", applicant.c1_score},
      {"C2", applicant.c2_score}
    ]

    {gramm_letter_score, grammar_highest_score} = Enum.max_by(scores_with_labels, fn {_label, value} -> Decimal.to_float(value) end)

    applicant = Map.put(applicant, :gramm_letter_score, gramm_letter_score)
    applicant = Map.put(applicant, :grammar_highest_score, grammar_highest_score |> Decimal.to_float())
    applicant
  end

  def get_chat_history(msisdn, campaign) do
    query = from(
      c in ChatHistory,
      where: c.msisdn == ^msisdn and c.campaign == ^campaign,
      order_by: [asc: c.id]
    )
    Repo.all(query)
  end

  def get_heat_check(msisdn, campaign) do
    query = from(hc in HrHeatCheck,
      join: a in HrApplicant,
      on: a.id == hc.applicant_id,
      join: j in HrJob,
      on: a.job_id == j.id,
      where: a.phone_sanitized == ^msisdn and j.va_campaign == ^campaign,
      limit: 1
    )
    Repo.one!(query)
  end
end
