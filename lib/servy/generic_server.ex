defmodule Servy.GenericServer do
  def start(callback_module, name, initial_state) do
    pid = spawn __MODULE__, :listen_loop, [initial_state, callback_module]
    Process.register(pid, name)
    pid
  end

  def stop(name) do
    case Process.whereis(name) do
      nil -> :ok
      pid ->
        Process.unregister(name)
        Process.exit(pid, :normal)
    end
  end

  def listen_loop(state, callback_module) do
    receive do
      {sender, :call, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        callback_module.handle_cast(message) |> listen_loop(callback_module)
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end

  def call(name, message) do
    send name, {self(), :call, message}

    receive do
      {:response, response} -> response
    end
  end

  def cast(name, message) do
    send name, {:cast, message}
  end
end
