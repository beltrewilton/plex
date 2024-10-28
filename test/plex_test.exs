defmodule PlexTest do
  use ExUnit.Case
  ExUnit.configure([timeout: :infinity, seed: 0])

  @msisdn  "18092239916"
  @campaign "CNVQSOUR84FK"
  @client_name "Jeim Schugar"

  setup do
    Plex.Repo.start_link()
    :ok
  end

  describe "The short happy path" do
    test "1 The first anonymous client request" do
      message = "Hi, this is my promo code CNVQSOUR84FK, I'm interested 💚!"
      is_flow = false

      client = Plex.State.new(@msisdn, message, "waid:0", is_flow, nil, false, false)

      assert {:ok, client} = Plex.State.message_handler(client)
    end

    test "2 complete the talent_entry_form (name, etc ...)" do
      is_flow = true

      Plex.Data.register_or_update(@msisdn, @client_name, 1, true, "yes", "yes", "Bonao", @campaign)

      message = "Ok, I completed, what's next?"

      client = Plex.State.new(@msisdn, message, "waid:0", is_flow, nil, false, false)

      assert {:ok, client} = Plex.State.message_handler(client)
    end

    test "3 client/applicant ask for concern" do
      is_flow = false

      message = "Will I be hired in the end?"

      client = Plex.State.new(@msisdn, message, "waid:0", is_flow, nil, false, false)

      assert {:ok, client} = Plex.State.message_handler(client)
    end

    test "4 client/applicant ask for some info" do
      is_flow = false

      message = "Ok, I completed, what's next?"

      client = Plex.State.new(@msisdn, message, "waid:0", is_flow, nil, false, false)

      assert {:ok, client} = Plex.State.message_handler(client)
    end

    test "5 grammar completed" do #TODO: expect share_link = true
      is_flow = true

      message = "completed"

      client = Plex.State.new(@msisdn, message, "waid:0", is_flow, nil, false, false)

      assert {:ok, client} = Plex.State.message_handler(client)
    end
  end


end
