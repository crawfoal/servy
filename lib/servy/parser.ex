defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, body] = String.split(request, "\r\n\r\n")

    [request | headers] = String.split(top, "\r\n")

    [method, path, _] = String.split(request, " ")

    headers = parse_headers(headers)

    params = parse_params(headers["Content-Type"], body)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(header_lines) do
    header_lines
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.reduce(%{}, fn([key, value], acc) -> Map.put(acc, key, value) end)
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2` into a map
  with corresponding keys and values.

  ## Examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", params_string)
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params("application/json", params_string) do
    params_string |> String.trim |> Poison.Parser.parse! |> atomize_keys
  end

  def parse_params(_, _), do: %{}

  defp atomize_keys(map) do
    for {k, v} <- map, into: %{}, do: {String.to_atom(k), v}
  end

end
