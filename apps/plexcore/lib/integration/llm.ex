defmodule Plex.LLM do
  @url "http://localhost:9091/llm/generate"

  @headers [
    {"accept", "application/json"},
    {"Content-Type", "application/json"}
  ]

  def generate(n_request) do
    body = Plex.Formater.transform_request(n_request)
    # n_request = Map.put(n_request, :state, n_request.app_states)
    # n_request = Map.delete(n_request, :app_states)
    # body = Jason.encode!(n_request)
    # IO.inspect(body)
    case HTTPoison.post(@url, body, @headers, timeout: 60_000 * 30, recv_timeout: 60_000 * 30) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        # IO.puts("Response: #{response_body}")
        Jason.decode!(response_body) |> Plex.Formater.transform_output()

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        IO.puts("Error: Received status code #{status_code}. Response: #{response_body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end

    # %Plex.State{}.n_response.output
  end
end

defmodule Plex.Formater do
  def transform_output(%{"output" => _output} = json) do
    response = %{
      output: %{
        response: json["output"]["response"],
        share_link: json["output"]["share_link"],
        schedule: json["output"]["schedule"],
        company_question: json["output"]["company_question"],
        abort_scheduled_state: json["output"]["abort_scheduled_state"]
      },
      previous_conversation_history: json["previous_conversation_history"]
    }

    # Map.put(json, "output", output)
    response
  end

  def transform_request(n_request) do
    %{
      "utterance" => n_request.utterance,
      "current_state" => format_state(n_request.current_state),
      "previous_state" => format_state(n_request.previous_state),
      "current_task" => format_task(n_request.current_task),
      "states" => format_states(n_request.app_states),
      "tasks" => format_tasks(n_request.tasks),
      "previous_conversation_history" => n_request.previous_conversation_history
    }
    |> Jason.encode!()
  end

  defp format_state(state) do
    case state do
      :in_progress ->
        Atom.to_string(:in_progress) |> String.replace("_", " ") |> String.capitalize()

      :scheduled ->
        "Scheduled"

      :completed ->
        "Completed"
    end
  end

  # defp format_state(_) do
  #   ""
  # end

  defp atom_to_str(atom_ref) do
    Atom.to_string(atom_ref) |> String.replace("_", " ") |> String.capitalize()
  end

  defp format_task(task) do
    case task do
      :talent_entry_form -> atom_to_str(:talent_entry_form)
      :grammar_assessment_form -> atom_to_str(:grammar_assessment_form)
      :scripted_text -> atom_to_str(:scripted_text)
      :open_question -> atom_to_str(:open_question)
      :end_of_task -> atom_to_str(:end_of_task)
    end
  end

  def format_states(states) do
    Enum.reduce(states, %{}, fn state, acc ->
      case state do
        :in_progress -> Map.put(acc, atom_to_str(:in_progress), "in_progress")
        :scheduled -> Map.put(acc, atom_to_str(:scheduled), "scheduled")
        :completed -> Map.put(acc, atom_to_str(:completed), "completed")
      end
    end)
  end

  def format_tasks(tasks) do
    Enum.reduce(tasks, %{}, fn task, acc ->
      case task do
        :talent_entry_form -> Map.put(acc, "1", atom_to_str(:talent_entry_form))
        :grammar_assessment_form -> Map.put(acc, "2", atom_to_str(:grammar_assessment_form))
        :scripted_text -> Map.put(acc, "3", atom_to_str(:scripted_text))
        :open_question -> Map.put(acc, "4", atom_to_str(:open_question))
        :end_of_task -> Map.put(acc, "5", atom_to_str(:end_of_task))
      end
    end)
  end
end
