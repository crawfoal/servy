defmodule Servy.PledgeController do
  alias Servy.PledgeServer

  import Servy.View, only: [render: 3]

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!" }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    render conv, 'pledges/index.eex', pledges: pledges
  end

  def new(conv) do
    render(conv, 'pledges/form.eex', pledge: %{name: '', amount: nil})
  end
end
