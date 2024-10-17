defmodule Machinery.Data do
  import Ecto.Query
  alias Machinery.Repo
  alias Machinery.ChatHistory

  alias GrammarScore
  alias SpeechScore
  alias SpeechLog

  def start_link, do: Repo.start_link()
  def data_mem_loader do
    chat_history = Repo.all(ChatHistory)
    Enum.each(
      chat_history,
      fn h -> IO.inspect(h.msisdn) end # perform put into memory-db
    )

    applicant_stage = Repo.all(Machinery.ApplicantStage)
    Enum.each(
      applicant_stage,
      fn a -> IO.inspect("#{a.msisdn} : #{a.task}") end # # perform put into memory-db
    )
  end

  def mark_as_collected(msisdn, campaign, sending_date) do
    from(ch in ChatHistory,
        where: ch.msisdn == ^msisdn
           and ch.campaign == ^campaign
           and ch.sending_date == ^sending_date
        )
    |> Repo.update_all(set: [collected: true])
  end

  def mark_as_readed(msisdn, campaign) do
    from(ch in ChatHistory,
    where: ch.msisdn == ^msisdn
      and  ch.campaign == ^campaign
      )
    |> Repo.update_all(set: [readed: true])
  end

  def add_chat_history_db(
    msisdn,
    campaign,
    message,
    source,
    whatsapp_id,
    sending_date \\ DateTime.utc_now(),
    readed \\ false,
    collected \\ false,
    output_llm_booleans \\ nil
  ) do
    changeset = %ChatHistory{}
    |> ChatHistory.changeset(%{
      msisdn: msisdn,
      campaign: campaign,
      message: message,
      source: source,
      whatsapp_id: whatsapp_id,
      sending_date: sending_date,
      readed: readed,
      collected: collected,
      output_llm_booleans: output_llm_booleans
    })
    case Repo.insert(changeset) do
        {:ok, chat_record} -> {:ok, chat_record}
        {:error, changeset} -> {:error, changeset}
    end
  end

  def get_hrapplicant(msisdn, campaign) do
    query = from a in HrApplicant,
      join: j in HrJob, on: a.job_id == j.id,
      where: a.phone_sanitized == ^msisdn and j.va_campaign == ^campaign,
      limit: 1
  end

  def update_applicant_stage(msisdn, campaign, task) do
    states = %{ # Odoo states/stages/kanva
      talent_entry_form: 1,
      grammar_assessment_form: 3,
      scripted_text: 3,
      open_question: 4,
      end_of_task: 5
    }

   query = get_hrapplicant(msisdn, campaign)

    case Repo.one(query) do
      nil -> Repo.rollback(:not_found)

      record -> Ecto.Changeset.change(record, %{stage_id: states[task]}) |> Repo.update()
    end
  end

  def get_job_by_campaign(campaign) do
    query = from j in HrJob,
     where: j.va_campaign == ^campaign

     case Repo.one(query) do
       nil -> {:not_found}
       record -> {:ok, record}
     end
  end


  @spec set_score(GrammarScore.t() | SpeechScore.t()) :: {:not_found} | {:error, any()} | {:ok, atom() | struct()}
  def set_score(score) do
    query = get_hrapplicant(score.msisdn, score.campaign)
    case Repo.one(query) do
      nil -> {:not_found}

      applicant ->
        IO.inspect(score)
        changeset = HrApplicant.changeset(applicant, Map.from_struct(score))
        IO.inspect(changeset)
        case Repo.update(changeset) do
          {:ok, _updated_applicant} ->
            {:ok, score}

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  @spec set_grammar_score(GrammarScore.t()) :: GrammarScore.t()
  def set_grammar_score(score \\ %GrammarScore{}) do
    set_score(score)
  end

  @spec set_speech_unscripted_score(SpeechScore.t()) :: SpeechScore.t()
  def set_speech_unscripted_score(score \\ %SpeechScore{}) do
    set_score(score)
  end

  def speech_log(log \\ %SpeechLog{}) do
    changeset = %SpeechLogSchema{} |> SpeechLogSchema.changeset(Map.from_struct(log))
    case Repo.insert(changeset) do
      {:ok, record} -> {:ok, record}
      {:error, changeset} -> {:error, changeset}
    end
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

  def applicant_register(%HrApplicant{} = appl, english_level) do
    skill = %HrApplicantSkill{}
    rel = %HrApplicantSkillRel{}
  
    Repo.transaction(fn ->
      appl
      |> Repo.insert!()
      |> then(fn appl ->
        skill
        |> Map.put(:applicant_id, appl.id)
        |> Map.put(:skill_level_id, english_level)
        |> Repo.insert!()
  
        rel
        |> Map.put(:hr_applicant_id, appl.id)
        |> Map.put(:hr_skill_id, 1)
        |> Repo.insert!()
      end)
    end)
    |> case do
      {:ok, _} -> :ok
      {:error, error} -> IO.inspect(error)
    end
  end

  def register_or_update(
    partner_phone,
    partner_name,
    english_level,
    is_valid_dominican_id,
    availability_tostart,
    availability_towork,
    city_residence,
    campaign
  ) do
  appl = get_hrapplicant(partner_phone, campaign)
  IO.inspect Repo.one(appl)

  case Repo.one(appl) do
    nil -> #TODO: maybe this never happen
      # Create new
      {:ok, job} = get_job_by_campaign(campaign)
      appl = %HrApplicant{
        partner_phone: partner_phone,
        partner_phone_sanitized: partner_phone,
        phone_sanitized: partner_phone,
        partner_mobile: partner_phone,
        partner_mobile_sanitized: partner_phone,
        is_valid_dominican_id: is_valid_dominican_id,
        availability_tostart: availability_tostart,
        availability_towork: availability_towork,
        city_residence: city_residence,
        name: job.name["en_US"],
        partner_name: partner_name,
        job_id: job.id
      }
      applicant_register(appl, english_level)

    applicant ->
      # Update existing
      Ecto.Changeset.change(applicant, %{
        partner_name: partner_name,
        is_valid_dominican_id: is_valid_dominican_id,
        availability_tostart: availability_tostart,
        availability_towork: availability_towork,
        city_residence: city_residence
      })
      |> Repo.update!()
      |> then(fn appl ->
        skill = %HrApplicantSkill{
          applicant_id: appl.id,
          skill_level_id: english_level
        }

        rel = %HrApplicantSkillRel{
          hr_applicant_id: appl.id,
          hr_skill_id: 1
        }

        Repo.insert!(skill)
        Repo.insert!(rel)
      end)
      # IO.inspect applicant
      # IO.puts("pura leña")
  end

  rescue
    e in Exception ->
      IO.inspect(e)
  end

  def register_without_name(msisdn, campaign) do
    #TODO: first: perform some memory logic
    {:ok, job} = get_job_by_campaign(campaign)
    appl = %HrApplicant{
      partner_phone: msisdn,
      partner_phone_sanitized: msisdn,
      phone_sanitized: msisdn,
      partner_mobile: msisdn,
      partner_mobile_sanitized: msisdn,
      name: job.name["en_US"],
      job_id: job.id
    }
    Repo.insert!(appl)
  end


end
