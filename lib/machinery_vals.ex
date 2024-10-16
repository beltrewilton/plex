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
          user_input_answer_2: String.t() | nil,
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


defmodule SpeechScore do
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
      speech_unscripted_audio_path: String.t()| nil,
      speech_unscripted_transcription: String.t()| nil,
      speech_unscripted_warning: String.t()| nil,
      speech_overall: float() | nil,
      speech_refText: String.t()| nil,
      speech_duration: float() | nil,
      speech_fluency: float() | nil,
      speech_integrity: float() | nil,
      speech_pronunciation: float() | nil,
      speech_rhythm: float() | nil,
      speech_speed: float() | nil,
      speech_audio_path: String.t()| nil,
      speech_warning: String.t()| nil
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
     :speech_warning,
  ]
end


defmodule SpeechLog do
  @type t :: %__MODULE__{
    create_uid: integer() | nil,
    write_uid: integer() | nil,
    msisdn: String.t() | nil,
    campaign: String.t() | nil,
    audio_path: String.t() | nil,
    response: map() | nil,
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

defmodule WebHookLog do
  @type t :: %__MODULE__{
    source: String.t() | nil,
    response: map() | nil,
    received_at: NaiveDateTime.t() | nil
  }

  defstruct [
    :source,
    :response,
    :received_at
  ]
end


defmodule CTALog do
  @type t :: %__MODULE__{
    referer: String.t() | nil,
    user_agent: String.t() | nil,
    campaign: String.t() | nil,
    received_at: NaiveDateTime.t() | nil
  }

  defstruct [
    :referer,
    :user_agent,
    :campaign,
    :received_at
  ]
end