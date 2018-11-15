defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "caches the three most recent pledges and total their amounts" do
    PledgeServer.start

    pledge_data = [{"Larry", 10}, {"Moe", 20}, {"Sally", 30}, {"Bob", 40}]
    Enum.each pledge_data, fn({name, amount}) ->
      PledgeServer.create_pledge(name, amount)
    end

    most_recent_pledges = [{"Bob", 40}, {"Sally", 30}, {"Moe", 20}]
    assert PledgeServer.recent_pledges == most_recent_pledges
    assert PledgeServer.total_pledged == 90

    PledgeServer.stop
  end

  test "clear out the cache" do
    PledgeServer.start
    PledgeServer.create_pledge("Sally", 10)

    PledgeServer.clear

    assert Enum.empty? PledgeServer.recent_pledges

    PledgeServer.stop
  end

  test "reset the cache size" do
    PledgeServer.start

    PledgeServer.set_cache_size(4)
    pledge_data = [{"Larry", 10}, {"Moe", 20}, {"Sally", 30}, {"Bob", 40}]
    Enum.each pledge_data, fn({name, amount}) ->
      PledgeServer.create_pledge(name, amount)
    end

    assert Enum.count(PledgeServer.recent_pledges) == 4

    PledgeServer.stop
  end

  test "init fetches recent pledges from service" do
    PledgeServer.start

    refute Enum.empty? PledgeServer.recent_pledges

    PledgeServer.stop
  end
end
