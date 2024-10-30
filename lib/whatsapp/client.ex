defmodule Whatsapp.Meta.Request do
  @meta_request [
    status_code: nil,
    waba_id: nil,
    phone_number_id: nil,
    display_phone_number: nil,
    wa_message_id: nil,
    sender_phone_number: nil,
    status: nil,
    billable: nil,
    category: nil,
    pricing_model: nil
  ]

  defstruct meta_request: @meta_request
end

defmodule Whatsapp.Client.Sender do
  @sender_request [
    status_code: nil,
    waba_id: nil,
    phone_number_id: nil,
    display_phone_number: nil,
    wa_message_id: nil,
    sender_phone_number: nil,
    message: nil,
    message_type: nil,
    flow: nil,
    audio_id: nil,
    scheduled: false,
    forwarded: false
  ]

  defstruct sender_request: @sender_request
end

defmodule Whatsapp.Client do
  alias WhatsappElixir.Static, as: WS

  def handle_notification(data) do
    case WS.get_message_type(data) do
      nil ->
        %Whatsapp.Meta.Request{
          meta_request: [
            status_code: 200,
            waba_id: WS.get_waba_id(data),
            phone_number_id: WS.get_phone_number_id(data),
            display_phone_number: WS.get_display_phone_number(data),
            wa_message_id: WS.get_message_id(data),
            sender_phone_number:  WS.get_mobile(data),
            status: WS.get_message_status(data),
            billable: WS.get_pricing_info(data, :billable),
            category: WS.get_pricing_info(data, :category),
            pricing_model: WS.get_pricing_info(data, :pricing_model)
          ]
        }

      _ ->
        %Whatsapp.Client.Sender{
          sender_request: [
            status_code: 200,
            waba_id: WS.get_waba_id(data),
            phone_number_id: WS.get_phone_number_id(data),
            display_phone_number: WS.get_display_phone_number(data),
            wa_message_id: WS.get_message_id(data),
            sender_phone_number:  WS.get_mobile(data),
            message: WS.get_message(data),
            message_type: WS.get_message_type(data),
            flow: WS.is_flow?(data),
            audio_id: WS.get_audio_id(data),
            scheduled: false,
            forwarded: WS.is_forwarded?(data)
          ]
        }
    end
  end
end
