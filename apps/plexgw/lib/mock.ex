defmodule Mockdata do
  def text(text, msisdn) do
    %{
      "entry" => [
        %{
          "changes" => [
            %{
              "field" => "messages",
              "value" => %{
                "contacts" => [
                  %{"profile" => %{"name" => "Wilton"}, "wa_id" => msisdn}
                ],
                "messages" => [
                  %{
                    "from" => msisdn,
                    "id" => "wamid.HBgLMTgyOTY0NTYxNzcVAgASGBQzQUM5MDY3RkI1MTgzMTU4RTlBQQA=",
                    "text" => %{"body" => text},
                    "timestamp" => "1727624931",
                    "type" => "text"
                  }
                ],
                "messaging_product" => "whatsapp",
                "metadata" => %{
                  "display_phone_number" => "18495266422",
                  "phone_number_id" => "427567963769591"
                }
              }
            }
          ],
          "id" => "442392808948818"
        }
      ],
      "object" => "whatsapp_business_account"
    }
  end

  def flow(msisdn) do
    %{
      "entry" => [
        %{
          "changes" => [
            %{
              "field" => "messages",
              "value" => %{
                "contacts" => [
                  %{
                    "profile" => %{"name" => "Wilton Gómez"},
                    "wa_id" => msisdn
                  }
                ],
                "messages" => [
                  %{
                    "context" => %{
                      "from" => "18495225777",
                      "id" => "wamid.HBgLMTg0OTYyNDgxNDkVAgARGBIwREY4MkJCNTdGQTMyNTA2RTgA"
                    },
                    "from" => msisdn,
                    "id" => "wamid.HBgLMTg0OTYyNDgxNDkVAgASGBQzQTMxMjFDQjA1MUExNzdDM0YwRAA=",
                    "interactive" => %{
                      "nfm_reply" => %{
                        "body" => "Sent",
                        "name" => "flow",
                        "response_json" =>
                          "{\"flow_token\":\"d4f06d12-e3db-44ac-b826-2e118aed941f\"}"
                      },
                      "type" => "nfm_reply"
                    },
                    "timestamp" => "1726610023",
                    "type" => "interactive"
                  }
                ],
                "messaging_product" => "whatsapp",
                "metadata" => %{
                  "display_phone_number" => "18495225777",
                  "phone_number_id" => "340502765810581"
                }
              }
            }
          ],
          "id" => "442392808948818"
        }
      ],
      "object" => "whatsapp_business_account"
    }
  end
end
