defmodule Plex.Flow do
  alias Plex.Data

  def register(decrypted_data) do
    data = decrypted_data["data"]
    # data["msisdn"]
    partner_phone = "18779001200"
    is_valid_dominican_id = data["is_valid_dominican_id"] == "1"
    availability_tostart = data["availability_tostart"]
    availability_towork = data["availability_towork"]
    # data["city_residence"]
    city_residence = "N/A"
    # data["campaign"]
    campaign = "CNVQSOUR84FK"
    partner_name = data["full_name"]
    english_level = String.to_integer(data["english_level"])

    Data.register_or_update(
      partner_phone,
      partner_name,
      english_level,
      is_valid_dominican_id,
      availability_tostart,
      availability_towork,
      city_residence,
      campaign
    )
  end

  def assessment(decrypted_data) do
    data = decrypted_data["data"]
    questions = [data["question_one"], data["question_two"]]
    answers = [data["answer_one"], data["answer_two"]]
    msisdn = data["msisdn"]
    campaign = data["campaign"]

    # TODO: validate grammar here:
  end

  def scheduler(decrypted_data) do
    # TODO: re-re-re-think scheduler MODULE
  end
end
