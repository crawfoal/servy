defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  use GenServer

  def init(args) do
    {:ok, args}
  end

  # Client interface functions
  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def stop do
    GenServer.stop(@name)
  end

  def bump_count(path) do
    GenServer.call(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts do
    GenServer.call(@name, :get_counts)
  end

  # Callback Functions
  def handle_call({:bump_count, path}, _from, state) do
    new_state = state |> Map.update(path, 1, &(&1 + 1))
    {:reply, nil, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    {:reply, state[path], state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end
end
