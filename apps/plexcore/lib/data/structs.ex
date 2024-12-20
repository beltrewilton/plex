defmodule GrammarScore do
  @type t :: %__MODULE__{
          msisdn: String.t() | nil,
          campaign: String.t() | nil,
          a1_score: float() | nil,
          a2_score: float() | nil,
          b1_score: float() | nil,
          b2_score: float() | nil,
          c1_score: float() | nil,
          c2_score: float() | nil,
          user_question_1: String.t() | nil,
          user_question_2: String.t() | nil,
          user_input_answer_1: String.t() | nil,
          user_input_answer_2: String.t() | nil
        }

  defstruct [
    :msisdn,
    :campaign,
    :a1_score,
    :a2_score,
    :b1_score,
    :b2_score,
    :c1_score,
    :c2_score,
    :user_question_1,
    :user_question_2,
    :user_input_answer_1,
    :user_input_answer_2
  ]
end

defmodule SpeechScriptedScore do
  @type t :: %__MODULE__{
          msisdn: String.t() | nil,
          campaign: String.t() | nil,
          speech_overall: float() | nil,
          speech_refText: String.t() | nil,
          speech_duration: float() | nil,
          speech_fluency: float() | nil,
          speech_integrity: float() | nil,
          speech_pronunciation: float() | nil,
          speech_rhythm: float() | nil,
          speech_speed: float() | nil,
          speech_audio_path: String.t() | nil,
          speech_warning: String.t() | nil
        }

  defstruct [
    :msisdn,
    :campaign,
    :speech_overall,
    :speech_refText,
    :speech_duration,
    :speech_fluency,
    :speech_integrity,
    :speech_pronunciation,
    :speech_rhythm,
    :speech_speed,
    :speech_audio_path,
    :speech_warning
  ]
end


defmodule SpeechUnScriptedScore do
  @type t :: %__MODULE__{
          msisdn: String.t() | nil,
          campaign: String.t() | nil,
          speech_open_question: String.t() | nil,
          speech_unscripted_overall_score: float() | nil,
          speech_unscripted_length: float() | nil,
          speech_unscripted_fluency_coherence: float() | nil,
          speech_unscripted_grammar: float() | nil,
          speech_unscripted_lexical_resource: float() | nil,
          speech_unscripted_pause_filler: map() | nil,
          speech_unscripted_pronunciation: float() | nil,
          speech_unscripted_relevance: float() | nil,
          speech_unscripted_speed: float() | nil,
          speech_unscripted_audio_path: String.t() | nil,
          speech_unscripted_transcription: String.t() | nil,
          speech_unscripted_warning: String.t() | nil
        }

  defstruct [
    :msisdn,
    :campaign,
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
    :speech_unscripted_audio_path,
    :speech_unscripted_transcription,
    :speech_unscripted_warning
  ]
end

defmodule SpeechLog do
  @type t :: %__MODULE__{
          create_uid: integer() | nil,
          write_uid: integer() | nil,
          msisdn: String.t() | nil,
          campaign: String.t() | nil,
          audio_path: String.t() | nil,
          response: map() | nil
        }

  defstruct [
    :create_uid,
    :write_uid,
    :msisdn,
    :campaign,
    :audio_path,
    :response
  ]
end

defmodule ApplicantStageStruct do
  @type t :: %__MODULE__{
          id: integer() | nil,
          create_uid: integer() | nil,
          write_uid: integer() | nil,
          msisdn: String.t() | nil,
          campaign: String.t() | nil,
          task: String.t() | nil,
          state: String.t() | nil,
          previous_state: String.t() | nil,
          last_update: NaiveDateTime.t() | nil,
          create_date: NaiveDateTime.t() | nil,
          write_date: NaiveDateTime.t() | nil
        }

  defstruct [
    :id,
    :create_uid,
    :write_uid,
    :msisdn,
    :campaign,
    :task,
    :state,
    :previous_state,
    :last_update,
    :create_date,
    :write_date
  ]

  def from_record([
        id,
        create_uid,
        write_uid,
        msisdn,
        campaign,
        task,
        state,
        previous_state,
        last_update,
        create_date,
        write_date
      ]) do
    %__MODULE__{
      id: id,
      create_uid: create_uid,
      write_uid: write_uid,
      msisdn: msisdn,
      campaign: campaign,
      task: task,
      state: state,
      previous_state: previous_state,
      last_update: last_update,
      create_date: create_date,
      write_date: write_date
    }
  end
end

defmodule ClientState do
  @type t :: %__MODULE__{
          waba_id: String.t() | nil,
          msisdn: String.t() | nil,
          message: String.t() | nil,
          campaign: String.t() | nil,
          whatsapp_id: String.t() | nil,
          state: String.t() | nil,
          previous_state: String.t() | nil,
          task: String.t() | nil,
          flow: boolean() | nil,
          audio_id: String.t() | nil,
          video_id: String.t() | nil,
          scheduled: boolean() | nil,
          forwarded: boolean() | nil
        }

  defstruct [
    :waba_id,
    :msisdn,
    :message,
    :campaign,
    :whatsapp_id,
    :state,
    :previous_state,
    :task,
    :flow,
    :audio_id,
    :video_id,
    :scheduled,
    :forwarded
  ]
end
