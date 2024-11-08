import Ecto.Query
defmodule Plex.Data do

  alias Plex.Repo
  alias Plex.ChatHistory
  alias Plex.ApplicantStage
  alias Plex.HrRecruitmentStage
  alias Plex.VaScheduler

  alias Plex.ZohoToken

  alias Plex.Data.Memory
  alias Util.Timez, as: T

  alias GrammarScore
  alias SpeechScore
  alias SpeechLog

  # import Logger

  # TODO: pending:
  # updated_collected_db

  def start_link(_args) do
    Memory.start()

    Repo.start_link()

    data_mem_loader()

    # Logger.info("data in memory loaded.")
  end

  def get_var(key) do
    System.fetch_env!(key)
  end

  defp data_mem_loader do
    chat_history = Repo.all(ChatHistory)

    Enum.each(
      chat_history,
      fn h ->
        Memory.add_chat_history(h, h.id)
      end
    )

    # chat_history = Enum.concat([chat_history | List.duplicate(chat_history, 100)])
    # Enum.reduce(chat_history, 1, fn h, counter ->
    #     Memory.add_chat_history(h, counter)
    #     counter + 1
    # end)

    applicant_stage = Repo.all(ApplicantStage)

    Enum.each(
      applicant_stage,
      fn a ->
        Memory.add_applicant_stage(a, a.id)
      end
    )
  end

  def add_applicant_stage(msisdn, campaign, task, state) do
    case Memory.get_applicant_stage(msisdn, campaign) do
      {:atomic, nil} ->
        changeset =
          %ApplicantStage{}
          |> ApplicantStage.changeset(%{
            create_uid: 1,
            write_uid: 1,
            msisdn: msisdn,
            campaign: campaign,
            task: task,
            state: state,
            last_update: T.now()
          })

        case Repo.insert(changeset) do
          {:ok, record} ->
            # TODO: first time????
            register_without_name(msisdn, campaign)
            Memory.add_applicant_stage(record, record.id)

          {:error, changeset} ->
            {:error, changeset}
        end

      {:atomic, _} ->
        IO.puts("Ya existe el par #{msisdn} #{campaign}, nada por hacer.")
    end
  end

  def get_stage(msisdn, campaign, task \\ :talent_entry_form, state \\ :in_progress) do
    appl_state = Memory.get_applicant_stage(msisdn, campaign)

    case appl_state do
      {:atomic, nil} ->
        query = from(s in ApplicantStage, where: s.msisdn == ^msisdn and s.campaign == ^campaign)

        case Repo.one(query) do
          nil ->
            add_applicant_stage(msisdn, campaign, task, state)

          record ->
            record

          _ ->
            :error
        end

        {:atomic, appl_state} = Memory.get_applicant_stage(msisdn, campaign)
        appl_state

      {:atomic, appl_state} ->
        appl_state

      _ ->
        {:error}
    end
  end

  def mark_as_collected(msisdn, campaign, sending_date) do
    from(ch in ChatHistory,
      where:
        ch.msisdn == ^msisdn and
          ch.campaign == ^campaign and
          ch.sending_date == ^sending_date
    )
    |> Repo.update_all(set: [collected: true])

    Memory.update_collected(msisdn, campaign, sending_date)
  end

  def mark_as_readed(msisdn, campaign) do
    from(ch in ChatHistory,
      where:
        ch.msisdn == ^msisdn and
          ch.campaign == ^campaign
    )
    |> Repo.update_all(set: [readed: true])

    Memory.mark_as_readed(msisdn, campaign)
  end

  def add_chat_history(
        msisdn,
        campaign,
        message,
        source,
        whatsapp_id,
        readed \\ false,
        collected \\ false,
        output_llm_booleans \\ nil
      ) do
    case add_chat_history_db(
           msisdn,
           campaign,
           message,
           source,
           whatsapp_id,
           T.now(),
           readed,
           collected,
           output_llm_booleans
         ) do
      {:ok, chat_history} ->
        Memory.add_chat_history(chat_history, chat_history.id)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp add_chat_history_db(
         msisdn,
         campaign,
         message,
         source,
         whatsapp_id,
         sending_date \\ T.now(),
         readed \\ false,
         collected \\ false,
         output_llm_booleans \\ nil
       ) do
    changeset =
      %ChatHistory{}
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
      {:ok, chat_history} -> {:ok, chat_history}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_hrapplicant(msisdn, campaign) do
    from(a in HrApplicant,
      join: j in HrJob,
      on: a.job_id == j.id,
      where: a.phone_sanitized == ^msisdn and j.va_campaign == ^campaign,
      limit: 1
    )
  end

  def update_hrapplicant(msisdn, campaign, task) do
    # Odoo states/stages/kanva
    odoo_states = %{
      talent_entry_form: 1,
      grammar_assessment_form: 3,
      scripted_text: 3,
      open_question: 4,
      end_of_task: 5
    }

    query = get_hrapplicant(msisdn, campaign)

    case Repo.one(query) do
      nil ->
        Repo.rollback(:not_found)

      record ->
        Ecto.Changeset.change(record, %{
          stage_id: odoo_states[task],
          lead_last_update: T.now()
        })
        |> Repo.update()
    end
  end

  # old name: odoo_update_state
  # TODO: call indepentdently
  # def odoo_update_state(msisdn, campaign, task, previous_task, state) do
  #   # juhhh?
  #   # if task in ["Talent entry form", "Grammar assessment form", "Scripted text", "Open question", "End_of_task"]:
  #   update_hrapplicant(msisdn, campaign, task)

  #   update_applicant_stage(msisdn, campaign, task, state)

  # end

  # old name: update_stage
  # really: update or insert
  def update_applicant_stage(msisdn, campaign, task, state) do
    query_update =
      from(a in ApplicantStage,
        where: a.msisdn == ^msisdn and a.campaign == ^campaign,
        select: a.id
      )

    applicant_stage =
      case Repo.update_all(query_update,
             set: [state: state, task: task, last_update: T.now()]
           ) do
        {0, _} ->
          # not found, insert
          IO.puts("Not found, INSERT")

          %ApplicantStage{}
          |> ApplicantStage.changeset(%{
            create_uid: 1,
            write_uid: 1,
            msisdn: msisdn,
            campaign: campaign,
            task: task,
            state: state,
            last_update: T.now()
          })
          |> Repo.insert!()

        {1, _applicant_stage} ->
          IO.puts("found, SO, GET applicant_stage")

          Repo.one!(
            from(a in ApplicantStage, where: a.msisdn == ^msisdn and a.campaign == ^campaign)
          )

        error ->
          error
      end

    Memory.add_applicant_stage(applicant_stage, applicant_stage.id)
  end

  # old name: get_applicant_state
  defp get_applicant_stage_name(msisdn, campaign) do
    query = get_hrapplicant(msisdn, campaign)

    case Repo.one(query) do
      nil ->
        :applican_not_found

      applicant ->
        query =
          from(a in HrRecruitmentStage,
            where: a.id == ^applicant.stage_id
          )

        case Repo.one(query) do
          nil -> :recruitment_not_found
          recuitment -> recuitment.name["en_US"]
        end
    end
  end

  # TODO: revisar, funciones cambiaron y afectan esta def...  WTF with this name?
  def set_state_all(_msisdn, _campaign, _state) do
    # {_, mem_state} = Memory.get_applicant_state(msisdn, campaign)
    # current_task = Enum.at(mem_state, 5)
    # current_state = Enum.at(mem_state, 6)

    # # memory_set  ->  previous_state
    # Memory.transitivity_set("previous_state", msisdn, campaign, current_state)

    # # update_stage -->
    # update_applicant_stage(msisdn, campaign, current_task, state)
    {:reevaluate}
  end

  def get_job_by_campaign(campaign) do
    query =
      from(j in HrJob,
        where: j.va_campaign == ^campaign
      )

    case Repo.one(query) do
      nil -> {:not_found}
      record -> {:ok, record}
    end
  end

  @spec set_score(GrammarScore.t() | SpeechScore.t()) ::
          {:not_found} | {:error, any()} | {:ok, atom() | struct()}
  def set_score(score) do
    query = get_hrapplicant(score.msisdn, score.campaign)

    case Repo.one(query) do
      nil ->
        {:not_found}

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

  defp applicant_register(%HrApplicant{} = appl, english_level) do
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
    IO.inspect(Repo.one(appl))

    case Repo.one(appl) do
      # TODO: maybe this never happen
      nil ->
        # Create new
        IO.inspect(campaign, label: "campaign: ")

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
    end

    # rescue
    #   e in Exception ->
    #     IO.inspect(e)
  end

  defp register_without_name(msisdn, campaign) do
    # TODO: first: perform some memory logic
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

  def applicant_scheduler(msisdn, campaign, scheduled_date) do
    params = %{
      msisdn: msisdn,
      campaign: campaign,
      scheduled_date: scheduled_date
    }

    appl = VaScheduler.changeset(%VaScheduler{}, params)

    Repo.insert!(appl)
  end

  def done_scheduler(msisdn, campaign) do
    Repo.update_all(
      from(s in VaScheduler, where: s.msisdn == ^msisdn and s.campaign == ^campaign),
      set: [done: true]
    )
  end

  def get_scheduled_applicants do
    from(
      a in VaScheduler,
      select: [:id, :msisdn, :campaign, :scheduled_date],
      where: a.scheduled_date > ^T.now(),
      where: a.done == false
    )
    |> Repo.all()
  end

  def get_access_token() do
    from(
      t in ZohoToken,
      limit: 1
    ) |> Repo.one()
  end

  def upsert_access_token(token, expires_at, old_token \\ nil) do
      case old_token do
        nil ->
          %ZohoToken{
            access_token: token,
            expires_at: expires_at
          }
          |> Repo.insert!()

        _ ->
          Repo.get_by(ZohoToken, access_token: old_token)
          |> ZohoToken.changeset(%{access_token: token, expires_at: expires_at})
          |> Repo.update!()
      end
  end
end
