defmodule Metex.Worker do
  @moduledoc """
  """
  def temperature_of(location) do
    result = location |> url_for |> HTTPoison.get |> parse_response
    case result do
      {:ok, temp} -> "#{location}: #{temp}°F"
      :error -> "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode location
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
      temp = (json["main"]["temp"] * 1.8 - 459.67) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
  end

  defp api_key do
    Application.get_env(:metex, :api_key)
  end
end
