defmodule UniqueCodeGenerator do
  @moduledoc """
  A module for generating unique codes with a given prefix.
  """

  @doc """
  Initialize a new UniqueCodeGenerator.

  ## Parameters
    - `prefix`: The prefix for the generated codes. Defaults to "CN".
    - `length`: The total length of the generated codes. Defaults to 12.

  ## Returns
    A new UniqueCodeGenerator struct.
  """
  defstruct [:prefix, :length, :generated_codes]

  def new(prefix \\ "CN", length \\ 12) do
    %UniqueCodeGenerator{
      prefix: prefix,
      length: length - String.length(prefix),
      generated_codes: MapSet.new()
    }
  end

  @doc """
  Generate a new unique code.

  ## Returns
    A new unique code as a string.
  """
  def generate_code(%UniqueCodeGenerator{
        prefix: prefix,
        length: length,
        generated_codes: generated_codes
      }) do
    random_part =
      Enum.map(1..length, fn _ -> Enum.random(~c'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') end)

    code = prefix <> to_string(random_part)

    if MapSet.member?(generated_codes, code) do
      generate_code(%UniqueCodeGenerator{
        prefix: prefix,
        length: length,
        generated_codes: generated_codes
      })
    else
      new_generated_codes = MapSet.put(generated_codes, code)

      %UniqueCodeGenerator{
        prefix: prefix,
        length: length,
        generated_codes: new_generated_codes
      }
      |> Map.put(:code, code)
    end
  end

  @doc """
  Extract codes from a given text.

  ## Parameters
    - `text`: The text to extract codes from.

  ## Returns
    A list of extracted codes.
  """
  def extract_code(text) do
    ~r/\bCN[A-Z0-9]{10}\b/
    |> Regex.scan(text)
    |> List.flatten()
  end
end
