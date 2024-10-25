defmodule Plex.Type.AtomString do
  use Ecto.Type

  def type, do: :string

  # def cast(atom) when is_atom(atom) do
  def cast(atom) when is_atom(atom) do
    # IO.inspect(atom, label: "cast: ")
    {:ok, Atom.to_string(atom)}
  end

  def cast(_), do: :error

  def load(string) when is_binary(string) do
    # IO.inspect(string, label: "load: ")
    {:ok, String.to_atom(string)}
  end

  def load(_), do: :error
  # def dump(atom) when is_atom(atom) do
  def dump(string) when is_binary(string) do
    # IO.inspect(string, label: "dump: ")
    {:ok, string}
  end

  def dump(_), do: :error
end
