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



end
