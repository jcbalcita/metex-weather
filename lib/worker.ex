defmodule Metex.Worker do
  alias Metex.Worker
  alias Metex.Coordinator

  def loop do
    receive do
      {sender_pid, location} -> send(sender_pid, {:ok, temperature_of(location)})
      _                      -> IO.puts "Unable to process this message"
    end
    loop()
  end

  def temperatures_of(cities) do
    coordinator = spawn(Coordinator, :loop, [[], Enum.count(cities)])

    cities |> Enum.each(fn city ->
      worker = spawn(Worker, :loop, [])
      send worker, {coordinator, city}
    end)
  end

  def temperature_of(location) do
    case raw_temperature_of(location) do
      {:ok, celsius} -> "#{location}: #{celsius} °C"
      :error         -> "Unable to find weather for #{location}"
    end
  end

  def fahrenheit_temp_of(location) do
    case raw_temperature_of(location) do
      {:ok, celsius} -> "#{location}: #{trunc((celsius * 1.8) + 32)} °F"
      :error         -> "Unable to find weather for #{location}"
    end
  end

  defp raw_temperature_of(location) do
    url_for(location) |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode! |> compute_temperature
  end

  defp parse_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  def api_key, do: Application.get_env(:metex, :api_key)
end