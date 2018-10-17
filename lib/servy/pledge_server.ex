defmodule Servy.PledgeServer do
  @name __MODULE__

  # Client interface functions
  def start do
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do
      {:response, pledge_id} -> pledge_id
    end
  end

  def recent_pledges do
    send @name, {self(), :recent_pledges}

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send @name, {self(), :total_pledged}

    receive do
      {:response, total} -> total
    end
  end

  # Server interface functions
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        pledge_id = post_pledge_to_service(name, amount)
        send sender, {:response, pledge_id}
        listen_loop([ {name, amount} | Enum.take(state, 2) ])
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
      {sender, :total_pledged} ->
        total = state |> Enum.map(&elem(&1, 1)) |> Enum.sum
        send sender, {:response, total}
        listen_loop(state)
      # TODO: handle unexpected message
    end
  end

  defp post_pledge_to_service(name, _amount) do
    "#{name}-#{:rand.uniform(1000)}"
  end
end
