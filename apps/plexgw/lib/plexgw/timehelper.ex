defmodule TimeHelper do
  @doc """
  Generates a list of time slots with 30-minute intervals.

  ## Parameters
  - start: The starting hour (1-24)
  - hours: The number of hours to generate time slots for
  - am: The AM/PM indicator ("AM" or "PM")

  ## Returns
  A list of time slots with their IDs and titles
  """
  def get_times(start, hours, am) do
    # Convert start hour to 24-hour format
    start_hour = convert_to_24_hour(start, am)

    # Generate time slots
    Enum.map(0..(hours * 2 - 1), fn i ->
      hour = start_hour + div(i, 2)
      minute = if rem(i, 2) == 0, do: 0, else: 30

      # Convert back to 12-hour format
      {hour, am_pm} = convert_to_12_hour(hour)
      title = "#{hour}:#{String.pad_leading(Integer.to_string(minute), 2, "0")} #{am_pm}"

      # Return time slot with ID and title
      %{id: i, title: title}
    end)
  end

  defp convert_to_24_hour(hour, "AM") when hour == 12, do: 0
  defp convert_to_24_hour(hour, "AM"), do: hour
  defp convert_to_24_hour(hour, "PM") when hour == 12, do: 12
  defp convert_to_24_hour(hour, "PM"), do: hour + 12

  defp convert_to_12_hour(hour) when hour == 0, do: {12, "AM"}
  defp convert_to_12_hour(hour) when hour == 12, do: {12, "PM"}
  defp convert_to_12_hour(hour) when hour > 12, do: {hour - 12, "PM"}
  defp convert_to_12_hour(hour), do: {hour, "AM"}
end
