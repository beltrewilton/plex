defmodule Plexui.PageController do
  use Plexui, :controller

  alias Plexui.Data

  def home(conn, %{"msisdn" => msisdn, "campaign" => campaign}) do
    # The home page is often custom made,
    # so skip the default app layout.
    applicant = Data.get_hrapplicant(msisdn, campaign)
    headers = Enum.into(conn.req_headers, %{})
    referer =
      case headers do
        %{"referer" => ref} ->
          if ref == "https://recruit.zoho.eu/", do: true, else: false
        _ -> false
      end

    chat_history = Data.get_chat_history(msisdn, campaign)

    heat_check = Data.get_heat_check(msisdn, campaign)

    render(conn, :home, page_title: applicant.partner_name, layout: false, applicant: applicant, referer: referer, chat_history: chat_history, heat_check: heat_check)
  end
end
