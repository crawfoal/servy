defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, body] = String.split(request, "\n\n")

    [request | headers] = String.split(top, "\n")

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

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}
end
