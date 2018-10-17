defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "caches the three most recent pledges and total their amounts" do
    PledgeServer.start
    pledge_data = [{'Larry', 10}, {'Moe', 20}, {'Sally', 30}, {'Bob', 40}]
    Enum.each pledge_data, fn({name, amount}) ->
      PledgeServer.create_pledge(name, amount)
    end

    most_recent_pledges = [{'Bob', 40}, {'Sally', 30}, {'Moe', 20}]
    assert PledgeServer.recent_pledges == most_recent_pledges
    assert PledgeServer.total_pledged == 90
  end
end
