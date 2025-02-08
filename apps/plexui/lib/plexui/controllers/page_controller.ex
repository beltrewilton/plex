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


    render(conn, :home, page_title: applicant.partner_name, layout: false, applicant: applicant, referer: true)
  end
end
