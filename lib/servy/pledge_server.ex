defmodule Servy.GenericServer do

end

defmodule Servy.PledgeServer do
  @name __MODULE__

  # Client interface functions
  def start do
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def stop do
    case Process.whereis(@name) do
      nil -> :ok
      pid ->
        Process.unregister(@name)
        Process.exit(pid, :normal)
    end
  end

  def create_pledge(name, amount) do
    call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    call(@name, :recent_pledges)
  end

  def total_pledged do
    call(@name, :total_pledged)
  end

  def clear do
    cast(@name, :clear)
  end

  # Helper Functions
  def call(name, message) do
    send name, {self(), :call, message}

    receive do
      {:response, response} -> response
    end
  end

  def cast(name, message) do
    send name, {:cast, message}
  end

  # Server interface functions
  def listen_loop(state) do
    receive do
      {sender, :call, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state)
      {:cast, message} ->
        handle_cast(message) |> listen_loop
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end
  end

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
