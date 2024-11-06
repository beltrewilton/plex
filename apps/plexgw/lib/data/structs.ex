defmodule WebHookLog do
  @type t :: %__MODULE__{
          source: String.t() | nil,
          response: map() | nil,
          waba_id: String.t() | nil,
          received_at: NaiveDateTime.t() | nil
        }

  defstruct [
    :source,
    :response,
    :waba_id,
    :received_at
  ]
end

defmodule CTALog do
  @type t :: %__MODULE__{
          referer: String.t() | nil,
          user_agent: String.t() | nil,
          campaign: String.t() | nil,
          waba_id: String.t() | nil,
          received_at: NaiveDateTime.t() | nil
        }

  defstruct [
    :referer,
    :user_agent,
    :campaign,
    :waba_id,
    :received_at
  ]
end
