import Ecto.Query

defmodule Plexui.Data do
  alias Plex.ChatHistory
  alias Plexui.Repo
  alias Elixlsx.{Workbook, Sheet}

  def start_link(_args) do
    Repo.start_link()
  end

  def get_hrapplicant(msisdn, campaign) do
    query =
      from(a in HrApplicant,
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

    {gramm_letter_score, grammar_highest_score} =
      Enum.max_by(scores_with_labels, fn {_label, value} -> Decimal.to_float(value) end)

    applicant = Map.put(applicant, :gramm_letter_score, gramm_letter_score)

    applicant =
      Map.put(applicant, :grammar_highest_score, grammar_highest_score |> Decimal.to_float())

    applicant
  end

  def get_chat_history(msisdn, campaign) do
    query =
      from(
        c in ChatHistory,
        where: c.msisdn == ^msisdn and c.campaign == ^campaign,
        order_by: [asc: c.id]
      )

    Repo.all(query)
  end

  def get_heat_check(msisdn, campaign) do
    query =
      from(hc in HrHeatCheck,
        join: a in HrApplicant,
        on: a.id == hc.applicant_id,
        join: j in HrJob,
        on: a.job_id == j.id,
        where: a.phone_sanitized == ^msisdn and j.va_campaign == ^campaign,
        limit: 1
      )

    Repo.one!(query)
  end

  def get_applicants_by_date(init_date, end_date) do  
    query =
        from(a in HrApplicant,
          join: j in HrJob, on: j.id == a.job_id,
          where: a.write_date >= ^init_date and a.write_date <= ^end_date,
          order_by: [desc: a.id],
          select: %{applicant: a, va_campaign: j.va_campaign}
        )

    data = Repo.all(query)

    header = [
      "partner_name",
      "partner_phone",
      "cedula_id",
      "availability_tostart",
      "work_permit",
      "business_location",
      "hear_about_us",
      "availability_towork",
      "a1_score",
      "a2_score",
      "b1_score",
      "b2_score",
      "c1_score",
      "c2_score",
      "speech_unscripted_overall_score",
      "speech_unscripted_length",
      "speech_unscripted_fluency_coherence",
      "speech_unscripted_grammar",
      "speech_unscripted_lexical_resource",
      "speech_unscripted_pronunciation",
      "speech_unscripted_relevance",
      "speech_unscripted_speed",
      "speech_overall",
      "speech_duration",
      "speech_fluency",
      "speech_integrity",
      "speech_pronunciation",
      "speech_rhythm",
      "speech_speed",
      "write_date",
      "va_campaign"
    ]

    rows =
      data
      |> Enum.map(fn %{applicant: applicant, va_campaign: va_campaign} ->
        [
          partner_name: applicant.partner_name,
                partner_phone: applicant.partner_phone,
                cedula_id: applicant.cedula_id,
                availability_tostart: applicant.availability_tostart,
                work_permit: applicant.work_permit,
                business_location: applicant.business_location,
                hear_about_us: applicant.hear_about_us,
                availability_towork: applicant.availability_towork,
                a1_score: applicant.a1_score,
                a2_score: applicant.a2_score,
                b1_score: applicant.b1_score,
                b2_score: applicant.b2_score,
                c1_score: applicant.c1_score,
                c2_score: applicant.c2_score,
                speech_unscripted_overall_score: applicant.speech_unscripted_overall_score,
                speech_unscripted_length: applicant.speech_unscripted_length,
                speech_unscripted_fluency_coherence: applicant.speech_unscripted_fluency_coherence,
                speech_unscripted_grammar: applicant.speech_unscripted_grammar,
                speech_unscripted_lexical_resource: applicant.speech_unscripted_lexical_resource,
                speech_unscripted_pronunciation: applicant.speech_unscripted_pronunciation,
                speech_unscripted_relevance: applicant.speech_unscripted_relevance,
                speech_unscripted_speed: applicant.speech_unscripted_speed,
                speech_overall: applicant.speech_overall,
                speech_duration: applicant.speech_duration,
                speech_fluency: applicant.speech_fluency,
                speech_integrity: applicant.speech_integrity,
                speech_pronunciation: applicant.speech_pronunciation,
                speech_rhythm: applicant.speech_rhythm,
                speech_speed: applicant.speech_speed,
                write_date: Calendar.strftime(applicant.write_date, "%Y-%m-%d %H:%M:%S"),
                va_campaign: va_campaign
        ]
      end)

    sheet = %Sheet{name: "Applicants", rows: [header | rows]}
    workbook = %Workbook{sheets: [sheet]}

    {:ok, Elixlsx.write_to_memory(workbook, "temp_file_applicant.xlsx")}
  end
end
