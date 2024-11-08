defmodule Plex.Flow do
  alias Plex.Data

  def register(decrypted_data) do
    data = decrypted_data["data"]
    partner_phone = data["msisdn"]
    is_valid_dominican_id = data["is_valid_dominican_id"] == "1"
    availability_tostart = data["availability_tostart"]
    availability_towork = data["availability_towork"]
    city_residence = "N/A"  # data["city_residence"]
    campaign = data["campaign"]
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
    answer_one = data["answer_one"]
    answer_two = data["answer_two"]
    answers = "#{answer_one},\n#{answer_two}"
    msisdn = data["msisdn"]
    campaign = data["campaign"]

    {probas, _p_max} = Grammar.score(answers)

    score = %GrammarScore{
      msisdn: msisdn,
      campaign: campaign,
      a1_score: probas[{0, "A1"}] * 100,
      a2_score: probas[{1, "A2"}] * 100,
      b1_score: probas[{2, "B1"}] * 100,
      b2_score: probas[{3, "B2"}] * 100,
      c1_score: probas[{4, "C1"}] * 100,
      c2_score: probas[{5, "C2"}] * 100,
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
