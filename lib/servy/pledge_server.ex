defmodule Servy.PledgeServer do
  @name __MODULE__

  alias Servy.GenericServer

  # Client interface functions

  def start do
    GenericServer.start(__MODULE__, @name, [])
  end

  def stop do
    GenericServer.stop(@name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  # Callback Functions

  def handle_call({:create_pledge, name, amount}, state) do
    {status, _} = post_pledge_to_service(name, amount)
    new_state = [ {name, amount} | Enum.take(state, 2) ]
    {status, new_state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call(:total_pledged, state) do
    total = state |> Enum.map(&elem(&1, 1)) |> Enum.sum
    {total, state}
  end

  def handle_cast(:clear), do: []

  defp post_pledge_to_service(name, amount) do
    url = "https://httparrot.herokuapp.com/post"
    body = ~s({"name": "#{name}", "amount": "#{amount}"})
    headers = [{"Content-Type", "application/json"}]
    HTTPoison.post url, body, headers
  end
end
