defmodule Plexui.PageController do
  use Plexui, :controller

  alias Plexui.Data
  alias Elixlsx.{Workbook, Sheet}

  def home(conn, %{"msisdn" => msisdn, "campaign" => campaign}) do
    # The home page is often custom made,
    # so skip the default app layout.
    applicant = Data.get_hrapplicant(msisdn, campaign)
    headers = Enum.into(conn.req_headers, %{})

    referer =
      case headers do
        %{"referer" => ref} ->
          if ref == "https://recruit.zoho.eu/", do: true, else: false

        _ ->
          false
      end

    chat_history = Data.get_chat_history(msisdn, campaign)

    heat_check = Data.get_heat_check(msisdn, campaign)

    render(conn, :home,
      page_title: applicant.partner_name,
      layout: false,
      applicant: applicant,
      referer: referer,
      chat_history: chat_history,
      heat_check: heat_check
    )
  end

  def report(conn, _params) do
    render(conn, :report, page_title: "Applicants Reports", layout: false)
  end

  def download(conn,  %{"startdate" => startdate, "enddate" => enddate}) do
    init_date = NaiveDateTime.from_iso8601!("#{startdate} 00:00:00.0")
    end_date = NaiveDateTime.from_iso8601!("#{enddate} 23:59:00.0")
    {_, {_, excel_content}} = Data.get_applicants_by_date(init_date, end_date)

    send_download(conn, {:binary, elem(excel_content, 1)}, [
        filename: "applicants-from-#{startdate}-to-#{enddate}.xlsx",
        content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ])
  end

  # def download(conn, _params) do
  #   init_date = NaiveDateTime.from_iso8601!("2025-02-21 00:00:00.0")
  #   end_date = NaiveDateTime.from_iso8601!("2025-02-21 23:59:00.0")


  #   case Data.get_applicants_by_date(init_date, end_date) do
  #     {:ok, excel_binary} ->  # Ensure we extract only the binary data
  #       conn
  #       |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  #       |> put_resp_header("content-disposition", "attachment; filename=report.xlsx")
  #       |> send_resp(200, excel_binary)

  #     {:error, reason} ->
  #       conn
  #       |> send_resp(500, "Failed to generate Excel file: #{inspect(reason)}")
  #   end
  # end

end
