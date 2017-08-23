defmodule Metex.Coordinator do
  @moduledoc """
  """
  def loop(results \\ [], num_expected_results) do
    receive do
      {:ok, result} ->
        new_results = [result|results]
        if num_expected_results == Enum.count(new_results) do
          send(self(), :exit)
        end
        loop(new_results, num_expected_results)
      :exit ->
        IO.puts(results |> Enum.sort |> Enum.join(", "))
    end
  end
end
