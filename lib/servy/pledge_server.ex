defmodule Servy.PledgeServer do
  @name __MODULE__

  use GenServer

  def init(args) do
    {:ok, args}
  end

  # Client interface functions

  def start do
    GenServer.start(__MODULE__, [], name: @name)
  end

  def stop do
    GenServer.stop(@name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  # Callback Functions

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {status, _} = post_pledge_to_service(name, amount)
    new_state = [ {name, amount} | Enum.take(state, 2) ]
    {:reply, status, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = state |> Enum.map(&elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_cast(:clear, _state), do: {:noreply, []}

  defp post_pledge_to_service(name, amount) do
    url = "https://httparrot.herokuapp.com/post"
    body = ~s({"name": "#{name}", "amount": "#{amount}"})
    headers = [{"Content-Type", "application/json"}]
    HTTPoison.post url, body, headers
  end
end
