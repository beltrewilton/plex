defmodule DummyStructBased do
  defstruct [:msisdn, :campaign]

  def new(msisdn, campaign) do
    %DummyStructBased{msisdn: msisdn, campaign: campaign}
  end

  def do_intelly_work(%DummyStructBased{} = client) do
    IO.inspect(client)
  end

end
