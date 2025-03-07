defmodule Plex.Flow do
  alias Plex.Data

  def register(decrypted_data) do
  #   "payload": {
  #     "full_name": "${screen.APPLICANT_BASIC.form.full_name}",
  #     "english_level": "${screen.APPLICANT_BASIC.form.english_level}",
  #     "availability_tostart": "${screen.APPLICANT_BASIC.form.availability_tostart}",

  #     "type_document_id": "${screen.APPLICANT_BASIC_EXTRA.form.type_document_id}",
  #     "cedula_id": "${screen.APPLICANT_BASIC_EXTRA.form.cedula_id}",
  #     "work_permit": "${screen.APPLICANT_BASIC_EXTRA.form.work_permit}",


  #     "availability_towork": "${form.availability_towork}",
  #     "business_location": "${form.business_location}",
  #     "hear_about_us": "${form.hear_about_us}",
  #     "terms_agreement": "${form.terms_agreement}",

  #     "msisdn": "${screen.APPLICANT_BASIC.data.msisdn}",
  #     "campaign": "${screen.APPLICANT_BASIC.data.campaign}",
  #     "waba_id": "${screen.APPLICANT_BASIC.data.waba_id}"
  # }
    data = decrypted_data["data"]

    IO.inspect(data, label: "Data Profile")

    partner_name = data["full_name"]
    english_level = String.to_integer(data["english_level"])
    availability_tostart = data["availability_tostart"]

    type_document_id = data["type_document_id"]
    cedula_id = data["cedula_id"]
    work_permit = data["work_permit"]

    availability_towork = data["availability_towork"]
    business_location = data["business_location"]
    hear_about_us = data["hear_about_us"]

    partner_phone = data["msisdn"]
    campaign = data["campaign"]
    # waba_id = data["waba_id"]


    Data.register_or_update(
      partner_phone,
      campaign,

      partner_name,
      english_level,
      availability_tostart,

      type_document_id,
      cedula_id,
      work_permit,

      availability_towork,
      business_location,
      hear_about_us
    )

    #TODO: `english_level` prepare a case to translate to ccd scales
    # 3.5+
    # 3.75
    # 4
    #TODO: availability_tostart

    {first_name, last_name} = split_name(partner_name)

    IO.inspect(first_name, label: "Zoho Client first_name")

    Integration.Zoho.add_candidate(last_name, first_name, "no@email.com", partner_phone, business_location, cedula_id, type_document_id, work_permit, english_level, availability_towork, hear_about_us)

    IO.puts("Integration.Zoho.add_candidate ended")

    m_event_response = Integration.MetaEvent.register_event("Submit application", partner_phone)

    IO.inspect(m_event_response, label: "Response register_event")
  end

  def split_name(name) do
    parts = String.split(name)
    case length(parts) do
      1 -> {name, ""}
      _ -> {Enum.at(parts, 0), Enum.join(Enum.drop(parts, 1), " ")}
    end
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

    scores_with_labels = [
      {"A1", score.a1_score},
      {"A2", score.a2_score},
      {"B1", score.b1_score},
      {"B2", score.b2_score},
      {"C1", score.c1_score},
      {"C2", score.c2_score}
    ]

    {label, _highest_score} = Enum.max_by(scores_with_labels, fn {_label, value} -> value end)

    Integration.Zoho.add_score(msisdn, label, :grammar)

  end

  def scheduler(decrypted_data) do
    # TODO: re-re-re-think scheduler MODULE
  end
end
