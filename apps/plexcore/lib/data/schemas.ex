defmodule Plex.ChatHistory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Util.Timez, as: T

  schema "va_chat_history" do
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:msisdn, :string)
    field(:campaign, :string)
    field(:source, :string)
    field(:whatsapp_id, :string)
    field(:message, :string)
    field(:readed, :boolean, default: false)
    field(:collected, :boolean, default: false)
    field(:sending_date, :naive_datetime_usec)
    field(:output_llm_booleans, :map)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :create_uid,
      :write_uid,
      :msisdn,
      :campaign,
      :source,
      :whatsapp_id,
      :message,
      :readed,
      :collected,
      :sending_date,
      :output_llm_booleans,
      :create_date,
      :write_date
    ])
    |> put_change(:create_date, T.now())
    |> put_change(:write_date, T.now())
  end
end

defmodule Plex.ApplicantStage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Util.Timez, as: T

  schema "va_applicant_stage" do
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:msisdn, :string)
    field(:campaign, :string)
    field(:task, Plex.Type.AtomString)
    field(:state, Plex.Type.AtomString)
    field(:previous_state, Plex.Type.AtomString)
    field(:last_update, :naive_datetime_usec)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :create_uid,
      :write_uid,
      :msisdn,
      :campaign,
      :task,
      :state,
      :last_update,
      :create_date,
      :write_date
    ])
    |> put_change(:create_date, T.now())
    |> put_change(:write_date, T.now())
  end
end

defmodule Plex.VaScheduler do
  use Ecto.Schema
  import Ecto.Changeset
  alias Util.Timez, as: T

  schema "va_scheduler" do
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:msisdn, :string)
    field(:campaign, :string)
    field(:done, :boolean, default: false)
    field(:scheduled_date, :naive_datetime_usec)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :create_uid,
      :write_uid,
      :msisdn,
      :campaign,
      :done,
      :scheduled_date,
      :create_date,
      :write_date
    ])
    |> put_change(:create_date, T.now())
    |> put_change(:write_date, T.now())
  end
end

defmodule Plex.HrRecruitmentStage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hr_recruitment_stage" do
    field(:name, :map)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :name
    ])
  end
end

defmodule HrApplicant do
  use Ecto.Schema
  import Ecto.Changeset
  alias Util.Timez, as: T

  schema "hr_applicant" do
    field(:campaign_id, :integer)
    field(:source_id, :integer)
    field(:medium_id, :integer)
    field(:message_bounce, :integer, default: 0)
    field(:message_main_attachment_id, :integer)
    field(:partner_id, :integer)
    field(:stage_id, :integer, default: 1)
    field(:last_stage_id, :integer)
    field(:company_id, :integer, default: 1)
    field(:user_id, :integer)
    field(:job_id, :integer, default: 1)
    field(:type_id, :integer)
    field(:department_id, :integer)
    field(:color, :integer, default: 0)
    field(:emp_id, :integer)
    field(:refuse_reason_id, :integer)
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:email_normalized, :string)
    field(:email_cc, :string)
    field(:name, :string)
    field(:email_from, :string)
    field(:priority, :string, default: "0")
    field(:salary_proposed_extra, :string)
    field(:salary_expected_extra, :string)
    field(:partner_name, :string)
    field(:partner_phone, :string)
    field(:partner_phone_sanitized, :string, default: nil)
    field(:phone_sanitized, :string, default: nil)
    field(:partner_mobile, :string)
    field(:partner_mobile_sanitized, :string, default: nil)
    field(:availability_tostart, :string)

    field(:type_document_id, :string)
    field(:cedula_id, :string)
    field(:work_permit, :string)
    field(:business_location, :string)
    field(:hear_about_us, :string)

    field(:availability_towork, :string)

    field(:kanban_state, :string, default: "normal")
    field(:linkedin_profile, :string)
    field(:availability, :date)
    field(:applicant_properties, :map)
    field(:description, :string)
    field(:active, :boolean, default: true)
    field(:date_closed, :naive_datetime_usec)
    field(:date_open, :naive_datetime_usec)
    field(:date_last_stage_update, :naive_datetime_usec)
    field(:probability, :float)
    field(:salary_proposed, :float, default: 0.0)
    field(:salary_expected, :float, default: 0.0)
    field(:delay_close, :float, default: 0.0)
    field(:a1_score, :decimal, default: 0.0)
    field(:a2_score, :decimal, default: 0.0)
    field(:b1_score, :decimal, default: 0.0)
    field(:b2_score, :decimal, default: 0.0)
    field(:c1_score, :decimal, default: 0.0)
    field(:c2_score, :decimal, default: 0.0)
    field(:user_question_1, :string)
    field(:user_question_2, :string)
    field(:user_input_answer_1, :string)
    field(:user_input_answer_2, :string)
    field(:lead_last_update, :naive_datetime_usec)
    field(:lead_last_client_update, :naive_datetime_usec)
    field(:lead_max_temperature, :float, default: 0.0)
    field(:speech_open_question, :string)
    field(:speech_unscripted_overall_score, :float, default: 0.0)
    field(:speech_unscripted_length, :float, default: 0.0)
    field(:speech_unscripted_fluency_coherence, :float, default: 0.0)
    field(:speech_unscripted_grammar, :float, default: 0.0)
    field(:speech_unscripted_lexical_resource, :float, default: 0.0)
    field(:speech_unscripted_pause_filler, :map)
    field(:speech_unscripted_pronunciation, :float, default: 0.0)
    field(:speech_unscripted_relevance, :float, default: 0.0)
    field(:speech_unscripted_speed, :float, default: 0.0)
    field(:speech_unscripted_transcription, :string)
    field(:speech_unscripted_audio_path, :string)
    field(:speech_unscripted_warning, :string)
    field(:speech_overall, :float, default: 0.0)
    field(:speech_refText, :string)
    field(:speech_duration, :float, default: 0.0)
    field(:speech_fluency, :float, default: 0.0)
    field(:speech_integrity, :float, default: 0.0)
    field(:speech_pronunciation, :float, default: 0.0)
    field(:speech_rhythm, :float, default: 0.0)
    field(:speech_speed, :float, default: 0.0)
    field(:speech_audio_path, :string)
    field(:video_path, :string)
    field(:speech_warning, :string)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :campaign_id,
      :source_id,
      :medium_id,
      :message_bounce,
      :message_main_attachment_id,
      :partner_id,
      :stage_id,
      :last_stage_id,
      :company_id,
      :user_id,
      :job_id,
      :type_id,
      :department_id,
      :color,
      :emp_id,
      :refuse_reason_id,
      :create_uid,
      :write_uid,
      :email_normalized,
      :email_cc,
      :name,
      :email_from,
      :priority,
      :salary_proposed_extra,
      :salary_expected_extra,
      :partner_name,
      :partner_phone,
      :partner_phone_sanitized,
      :phone_sanitized,
      :partner_mobile,
      :partner_mobile_sanitized,

      :availability_tostart,
      :type_document_id,
      :cedula_id,
      :work_permit,
      :business_location,
      :hear_about_us,
      :availability_towork,

      :kanban_state,
      :linkedin_profile,
      :availability,
      :applicant_properties,
      :description,
      :active,
      :date_closed,
      :date_open,
      :date_last_stage_update,
      :probability,
      :salary_proposed,
      :salary_expected,
      :delay_close,
      :speech_warning,
      :a1_score,
      :a2_score,
      :b1_score,
      :b2_score,
      :c1_score,
      :c2_score,
      :user_question_1,
      :user_question_2,
      :user_input_answer_1,
      :user_input_answer_2,
      :lead_last_update,
      :lead_last_client_update,
      :lead_max_temperature,
      :speech_open_question,
      :speech_unscripted_overall_score,
      :speech_unscripted_length,
      :speech_unscripted_fluency_coherence,
      :speech_unscripted_grammar,
      :speech_unscripted_lexical_resource,
      :speech_unscripted_pause_filler,
      :speech_unscripted_pronunciation,
      :speech_unscripted_relevance,
      :speech_unscripted_speed,
      :speech_unscripted_transcription,
      :speech_unscripted_audio_path,
      :speech_unscripted_warning,
      :speech_overall,
      :speech_refText,
      :speech_duration,
      :speech_fluency,
      :speech_integrity,
      :speech_pronunciation,
      :speech_rhythm,
      :speech_speed,
      :speech_audio_path,
      :video_path,
      :create_date,
      :write_date
    ])
    |> put_change(:create_date, T.now())
    |> put_change(:write_date, T.now())
  end
end

defmodule HrApplicantSkill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hr_applicant_skill" do
    field(:applicant_id, :integer)
    field(:skill_id, :integer, default: 1)
    field(:skill_level_id, :integer)
    field(:skill_type_id, :integer, default: 1)
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :applicant_id,
      :skill_id,
      :skill_level_id,
      :skill_type_id,
      :create_uid,
      :write_uid
    ])
    |> validate_required([:applicant_id, :skill_level_id])
  end
end

defmodule HrApplicantSkillRel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "hr_applicant_hr_skill_rel" do
    # , primary_key: true
    field(:hr_applicant_id, :integer)
    field(:hr_skill_id, :integer, default: 1)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:hr_applicant_id, :hr_skill_id])
  end

  # def insert(changeset) do
  #   Plex.Repo.insert(changeset)
  # end
end

defmodule HrJob do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hr_job" do
    field(:sequence, :integer)
    field(:expected_employees, :integer)
    field(:no_of_employee, :integer)
    field(:no_of_recruitment, :integer)
    field(:no_of_hired_employee, :integer)
    field(:department_id, :integer)
    field(:company_id, :integer)
    field(:contract_type_id, :integer)
    field(:create_uid, :integer)
    field(:write_uid, :integer)
    field(:name, :map)
    field(:description, :string)
    field(:requirements, :string)
    field(:active, :boolean)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
    field(:alias_id, :integer)
    field(:address_id, :integer)
    field(:manager_id, :integer)
    field(:user_id, :integer)
    field(:color, :integer)
    field(:applicant_properties_definition, :map)
    field(:va_campaign, :string)
    field(:wa_text, :string)
    field(:wa_phone, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :sequence,
      :expected_employees,
      :no_of_employee,
      :no_of_recruitment,
      :no_of_hired_employee,
      :department_id,
      :company_id,
      :contract_type_id,
      :create_uid,
      :write_uid,
      :name,
      :description,
      :requirements,
      :active,
      :create_date,
      :write_date,
      :alias_id,
      :address_id,
      :manager_id,
      :user_id,
      :color,
      :applicant_properties_definition,
      :va_campaign,
      :wa_text,
      :wa_phone
    ])
  end
end

defmodule SpeechLogSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "va_speech_log" do
    field(:create_uid, :integer, default: 1)
    field(:write_uid, :integer, default: 1)
    field(:msisdn, :string)
    field(:campaign, :string)
    field(:audio_path, :string)
    field(:response, :map)
    field(:create_date, :naive_datetime_usec)
    field(:write_date, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :create_uid,
      :write_uid,
      :msisdn,
      :campaign,
      :audio_path,
      :response
    ])
    |> validate_required([
      :msisdn,
      :campaign
    ])
  end
end


defmodule Plex.FlowHeaders do
  use Ecto.Schema
  import Ecto.Changeset

  schema "va_flow_headers" do
    field(:header_name, :string)
    field(:base64_string, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :header_name,
      :base64_string
    ])
  end
end

defmodule Plex.ZohoToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "va_zoho_token" do
    field(:access_token, :string)
    field(:expires_at, :naive_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :access_token,
      :expires_at
    ])
  end
end
