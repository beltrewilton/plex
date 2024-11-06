defmodule Grammar do
  use GenServer
  require Nx

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

    # model = Bumblebee.Text.token_classification(model, tokenizer, aggregation: :same)

    # {model, tokenizer} = XGrammarProbas.start
    # XGrammarProbas.score(model, tokenizer)

    # inputs = Bumblebee.apply_tokenizer(tokenizer, "Hi there")
    # output = Axon.predict(model.model, model.params, inputs)
    # logits = output[:logits]
    # softmax = Nx.divide(Nx.exp(logits), Nx.sum(Nx.exp(logits)))
    # probas = Nx.to_flat_list(softmax)
    # probabilities_map = Enum.zip(model.spec.id_to_label, probas) |> Enum.into(%{})
    # p_max = Enum.max_by(probabilities_map, fn {_k, v} -> v end) |> elem(0)
  end

  def score(text \\ "Hi this is a test") do
    GenServer.call(__MODULE__, {:score, text})
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :model_loader}}
  end

  @impl true
  def handle_continue(:model_loader, _state) do
    {:ok, tokenizer} =
      Bumblebee.load_tokenizer(
        {:hf, "hafidikhsan/distilbert-base-uncased-english-cefr-lexical-evaluation-dt-v1"}
      )

    {:ok, model} =
      Bumblebee.load_model(
        {:hf, "hafidikhsan/distilbert-base-uncased-english-cefr-lexical-evaluation-dt-v1"},
        architecture: :for_sequence_classification
        # for_token_classification
      )

    IO.puts("Model loaded ...")

    {:noreply, %{model: model, tokenizer: tokenizer}}
  end

  @impl true
  def handle_call({:score, text}, _from, state) do
    inputs = Bumblebee.apply_tokenizer(state.tokenizer, text)
    output = Axon.predict(state.model.model, state.model.params, inputs)
    logits = output[:logits]
    softmax = Nx.divide(Nx.exp(logits), Nx.sum(Nx.exp(logits), axes: [1]))
    probas = Nx.to_flat_list(softmax)
    probabilities_map = Enum.zip(state.model.spec.id_to_label, probas) |> Enum.into(%{})
    p_max = Enum.max_by(probabilities_map, fn {_k, v} -> v end) |> elem(0)

    {:reply, {probabilities_map, p_max}, state}
  end
end
