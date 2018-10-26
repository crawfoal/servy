defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  alias Servy.GenericServer

  # Client interface functions
  def start do
    GenericServer.start(__MODULE__, @name, %{})
  end

  def stop do
    GenericServer.stop(@name)
  end

  def bump_count(path) do
    GenericServer.call(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenericServer.call(@name, {:get_count, path})
  end

  def get_counts do
    GenericServer.call(@name, :get_counts)
  end

  # Callback Functions
  def handle_call({:bump_count, path}, state) do
    new_state = state |> Map.update(path, 1, &(&1 + 1))
    {nil, new_state}
  end

  def handle_call({:get_count, path}, state) do
    {state[path], state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end
end
