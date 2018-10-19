defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  # Client interface functions
  def start do
    pid = spawn(__MODULE__, :listen_loop, [%{}])
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

  def bump_count(path) do
    send @name, {self(), :bump_count, path}

    receive do {:response} -> :ok end
  end

  def get_count(path) do
    send @name, {self(), :get_count, path}

    receive do {:response, count} -> count end
  end

  def get_counts do
    send @name, {self(), :get_counts}

    receive do {:response, count_map} -> count_map end
  end

  # Server interface fucntions
  def listen_loop(state) do
    receive do
      {sender, :bump_count, path} ->
        state = state |> Map.update(path, 1, &(&1 + 1))
        send sender, {:response}
        listen_loop(state)
      {sender, :get_count, path} ->
        send sender, {:response, state[path]}
        listen_loop(state)
      {sender, :get_counts} ->
        send sender, {:response, state}
        listen_loop(state)
    end
  end
end
