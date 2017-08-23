defmodule Metex do
  @moduledoc """
  """
  @spec temperature_of([String]) :: any
  def temperature_of(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])
    cities |> Enum.each(fn city ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send worker_pid, {coordinator_pid, city}
    end)
  end
end
