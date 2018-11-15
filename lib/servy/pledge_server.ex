defmodule Servy.PledgeServer do
  @name __MODULE__

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def init(args) do
    {:ok, args}
  end

  # Client interface functions

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
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

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  # Callback Functions

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {status, _} = post_pledge_to_service(name, amount)
    cached_pledges = [ {name, amount} | Enum.take(state.pledges, state.cache_size - 1) ]
    new_state = %{ state | pledges: cached_pledges }
    {:reply, status, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = state.pledges |> Enum.map(&elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_cast(:clear, state), do: {:noreply, %{ state | pledges: [] }}

  def handle_cast({:set_cache_size, size}, state) do
    { :noreply, %{ state | cache_size: size } }
  end

  defp post_pledge_to_service(name, amount) do
    url = "https://httparrot.herokuapp.com/post"
    body = ~s({"name": "#{name}", "amount": "#{amount}"})
    headers = [{"Content-Type", "application/json"}]
    HTTPoison.post url, body, headers
  end
end
