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
    answers = [data["answer_one"], data["answer_two"]]
    msisdn = data["msisdn"]
    campaign = data["campaign"]

    {probas, _p_max} = Grammar.score(answers)

    score = %GrammarScore{
      msisdn: msisdn,
      campaign: campaign,
      a1_score: probas[{0, "A1"}],
      a2_score: probas[{1, "A2"}],
      b1_score: probas[{2, "B1"}],
      b2_score: probas[{3, "B2"}],
      c1_score: probas[{4, "C1"}],
      c2_score: probas[{5, "C2"}],
      user_question_1: data["question_one"],
      user_question_2: data["question_two"],
      user_input_answer_1: data["answer_one"],
      user_input_answer_2: data["answer_two"]
    }

    Data.set_grammar_score(score)
  end

  def scheduler(decrypted_data) do
    # TODO: re-re-re-think scheduler MODULE
  end
end
