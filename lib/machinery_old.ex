defmodule MachineryOld do
  alias Venomous.SnakeArgs

  def entry(:ok, message) do
    IO.puts(message)
    {:ok, python} = :python.start_link([{:python_path, ~c"/Users/beltre.wilton/apps/plex/lib"}, {:python, ~c'python3'}])
    result = :python.call(python, :dummy, :dummy_func, ["Wilton Beltré"])
    {:reply, result}
  end

  def init do
    case :python.start_link([{
        :python_path,
        ~c'/Users/beltre.wilton/apps/tars:/Users/beltre.wilton/apps/tars/samantha/src:/Users/beltre.wilton/miniforge3/envs/tars_env/lib/python3.10/site-packages'
      },
      {:python, ~c'python3'}
      ]) do
      {:ok, python} -> {:ok, python}
      {_, reason} -> {:error, reason}
    end
  end

  def generate(python) do
    result = :python.call(python, :dspy_models, :generate, [
        "Hi, what's up!",
        %{"In Progress" => "in_progress", "Scheduled" => "scheduled", "Completed" => "completed"},
        "In Progress",
        "N/A",
        %{
          "1" => "Talent entry form",
          "2" => "Grammar assessment form",
          "3" => "Scripted text",
          "4" => "Open question",
          "5" => "End_of_task"
        },
        "Talent entry form",
        [
          "Hi, this is mi firts comment."
        ]
      ]
    )
    IO.puts(result)
    {:reply, result}
  end

  def enum_test(range, python) do
    Enum.map(
      range,
      fn _ -> MachineryOld.generate(python) end
    )
    {:ok}
  end

  def timeit(range) do
    {_, python_pid} = MachineryOld.init
    {runtime, _} = :timer.tc(MachineryOld, :enum_test, [range, python_pid])
    IO.puts("ERLPort Performance for #{Enum.count(range)} iterations at: #{runtime/1_000_000} seconds.")
  end

  @url "http://localhost:9091/llm/generate"

  def build_body_headers do
    headers = [
      {"accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      "utterance" => "Hey you!",
      "current_state" => "In Progress",
      "previous_state" => "",
      "current_task" => "Talent entry form",
      "states" => %{
        "In Progress" => "in_progress",
        "Scheduled" => "scheduled",
        "Completed" => "completed"
      },
      "tasks" => %{
        "1" => "Talent entry form",
        "2" => "Grammar assessment form",
        "3" => "Scripted text",
        "4" => "Open question",
        "5" => "End_of_task"
      },
      "previous_conversation_history" => [
        "Hi, this is mi firts comment."
      ]
    }
    |> Jason.encode!()

    {body, headers}
  end

  def send_post_request(body, headers) do
    case HTTPoison.post(@url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        IO.puts("Response: #{response_body}")
        Jason.decode!(response_body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        IO.puts("Error: Received status code #{status_code}. Response: #{response_body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end
  end

  def enum_test_http(range, body, headers) do
    Enum.map(
      range,
      fn _ -> MachineryOld.send_post_request(body, headers) end
    )
    {:ok}
  end

  def timeit_http(range) do
    {body, headers} = MachineryOld.build_body_headers
    {runtime, _} = :timer.tc(MachineryOld, :enum_test_http, [range, body, headers])
    IO.puts("HTTP Performance for #{Enum.count(range)} iterations at: #{runtime/1_000_000} seconds.")
  end

  def test_venom(message \\ "Hi there") do
    params = [
      message,
      %{"In Progress" => "in_progress", "Scheduled" => "scheduled", "Completed" => "completed"},
      "In Progress",
      "N/A",
      %{
        1 => "Talent entry form",
        2 => "Grammar assessment form",
        3 => "Scripted text",
        4 => "Open question",
        5 => "End_of_task"
      },
      "Talent entry form",
      [
        "Hi, this is mi firts comment."
      ]
    ]
    SnakeArgs.from_params(:dspy_models, :generate, params) |> Venomous.python()
  end
end
