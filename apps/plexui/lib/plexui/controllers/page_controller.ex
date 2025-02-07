defmodule Plexui.PageController do
  use Plexui, :controller

  alias Plexui.Data

  def home(conn, %{"msisdn" => msisdn, "campaign" => campaign}) do
    # The home page is often custom made,
    # so skip the default app layout.
    applicant = Data.get_hrapplicant(msisdn, campaign)
    render(conn, :home, layout: false, applicant: applicant)
  end
end
