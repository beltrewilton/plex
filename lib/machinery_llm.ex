defmodule Machinery.Llm do
  @url "http://localhost:9091/llm/generate"

  @headers  [
    {"accept", "application/json"},
    {"Content-Type", "application/json"}
  ]

  def generate(n_request) do
    body = Transformer.transform_request(n_request)
    # n_request = Map.put(n_request, :state, n_request.app_states)
    # n_request = Map.delete(n_request, :app_states)
    # body = Jason.encode!(n_request)
    # IO.inspect(body)
    case HTTPoison.post(@url, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        IO.puts("Response: #{response_body}")
        Jason.decode!(response_body) |> Transformer.transform_output()

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        IO.puts("Error: Received status code #{status_code}. Response: #{response_body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end
    %Machinery{}.n_response.output
  end
end

defmodule Transformer do
  def transform_output(%{"output" => output} = json) do
    output = %{
      response: "random text",
      share_link: output["share_link"],
      schedule: output["schedule"],
      company_question: false,
      abort_scheduled_state: output["abort_scheduled_state"]
    }

    Map.put(json, "output", output)
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
    } |> Jason.encode!()
  end

  defp format_state(state) do
    case state do
      :in_progress -> Atom.to_string(:in_progress) |> String.replace("_", " ") |> String.capitalize()
      :scheduled -> "Scheduled"
      :completed -> "Completed"
    end
  end

  defp format_state(_) do
    ""
  end

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

  defp format_states(states) do
    Enum.reduce(states, %{}, fn state, acc ->
      case state do
        :in_progress -> Map.put(acc, atom_to_str(:in_progress), "in_progress")
        :scheduled -> Map.put(acc, atom_to_str(:scheduled), "scheduled")
        :completed -> Map.put(acc, atom_to_str(:completed), "completed")
      end
    end)
  end

  defp format_tasks(tasks) do
    Enum.reduce(tasks, %{}, fn {task, id}, acc ->
      case task do
        :talent_entry_form -> Map.put(acc, "#{id}", atom_to_str(:talent_entry_form))
        :grammar_assessment_form -> Map.put(acc, "#{id}", atom_to_str(:grammar_assessment_form))
        :scripted_text -> Map.put(acc, "#{id}", atom_to_str(:scripted_text))
        :open_question -> Map.put(acc, "#{id}", atom_to_str(:open_question))
        :end_of_task -> Map.put(acc, "#{id}", atom_to_str(:end_of_task))
      end
    end)
  end
end
