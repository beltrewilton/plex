defmodule Whatsapp.Client do
  alias WhatsappElixir.Static, as: WS

  defstruct [
    status_code: nil,
    whatsapp_id: nil,
    phone_number: nil,
    message: nil,
    message_type: nil,
    flow: nil,
    audio_id: nil,
    scheduled: false,
    forwarded: false
  ]

  def handle_notification(data) do
    %__MODULE__{
      status_code: 200,
      whatsapp_id: WS.get_message_id(data),
      phone_number:  WS.get_mobile(data),
      message: WS.get_message(data),
      message_type: WS.get_message_type(data),
      flow: WS.is_flow?(data),
      audio_id: WS.get_audio_id(data),
      scheduled: false,
      forwarded: WS.is_forwarded?(data)
    }
  end
end
