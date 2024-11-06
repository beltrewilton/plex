defmodule XGrammarProbas do
  alias Bumblebee.Text
  alias Bumblebee.Text.DistilBert
  alias Nx.Tensor
  alias Nx.Defn
  require Nx

  def start() do
    {:ok, tokenizer} =
      Bumblebee.load_tokenizer(
        {:hf, "hafidikhsan/distilbert-base-uncased-english-cefr-lexical-evaluation-dt-v1"}
      )

    {:ok, model} =
      Bumblebee.load_model(
        {:hf, "hafidikhsan/distilbert-base-uncased-english-cefr-lexical-evaluation-dt-v1"},
        architecture: :for_sequence_classification
        # for_sequence_classification
        # for_token_classification
      )

    # model = Bumblebee.Text.token_classification(model, tokenizer, aggregation: :same)


    # {model, tokenizer} = XGrammarProbas.start
    # XGrammarProbas.grammar_probas_scores(model, tokenizer)


    # inputs = Bumblebee.apply_tokenizer(tokenizer, "Hi there")
    # output = Axon.predict(model.model, model.params, inputs)
    # logits = output[:logits]
    # softmax = Nx.divide(Nx.exp(logits), Nx.sum(Nx.exp(logits)))
    # probas = Nx.to_flat_list(softmax)
    # probabilities_map = Enum.zip(model.spec.id_to_label, probas) |> Enum.into(%{})
    # p_max = Enum.max_by(probabilities_map, fn {_k, v} -> v end) |> elem(0)


    {model, tokenizer}
  end

  # Function to compute probabilities
  def grammar_probas_scores(model, tokenizer, answer \\ "Hi this is a test") do
    answer = "Last weekend, I visited a local festival in my hometown. It was a really enjoyable event with lots of food, music, and activities. There were many stalls selling traditional crafts and local specialties. I tried some delicious local dishes, including a traditional dessert called tiramisu. The music was great too, with a mix of rock and pop bands performing on stage. One of the highlights was a fireworks display at the end of the night. Overall, it was a fantastic festival and I'm glad I went. I would definitely recommend it to anyone looking for a fun day out."
    inputs = Bumblebee.apply_tokenizer(tokenizer, answer)
    output = Axon.predict(model.model, model.params, inputs)
    logits = output[:logits]
    softmax = Nx.divide(Nx.exp(logits), Nx.sum(Nx.exp(logits), axes: [1]))
    probas = Nx.to_flat_list(softmax)
    probabilities_map = Enum.zip(model.spec.id_to_label, probas) |> Enum.into(%{})
    p_max = Enum.max_by(probabilities_map, fn {_k, v} -> v end) |> elem(0)

    {probabilities_map, p_max}
  end
end
