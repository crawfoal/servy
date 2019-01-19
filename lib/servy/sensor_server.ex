defmodule Servy.SensorServer do

  @name :sensor_server

  use GenServer

  defmodule State do
    @refresh_interval :timer.minutes(60)

    defstruct sensor_data: %{},
              refresh_interval: @refresh_interval,
              next_refresh: nil
  end

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def start_link(interval) do
    IO.puts "Starting the sensor server with #{interval} min refresh..."
    initial_state = %State{refresh_interval: :timer.minutes(interval)}
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(interval_in_ms) do
    GenServer.cast @name, {:set_refresh_interval, interval_in_ms}
  end

  # Server Callbacks

  def init(state) do
    initial_sensor_data = run_tasks_to_get_sensor_data()
    state = schedule_refresh(state)
    {:ok, %State{ state | sensor_data: initial_sensor_data }}
  end

  defp schedule_refresh(state) do
    next_refresh = Process.send_after(self(), :refresh, state.refresh_interval)
    %State{ state | next_refresh: next_refresh }
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache..."
    new_sensor_data = run_tasks_to_get_sensor_data()
    state = schedule_refresh(state)
    {:noreply, %State{ state | sensor_data: new_sensor_data }}
  end

  def handle_info(unexpected, state) do
    IO.puts "Can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  def handle_cast({ :set_refresh_interval, interval_in_ms }, state) do
    Process.cancel_timer(state.next_refresh)
    state = %State{ state | refresh_interval: interval_in_ms } |> schedule_refresh
    {:noreply, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
