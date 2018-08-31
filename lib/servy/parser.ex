defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, body] = String.split(request, "\n\n")

    [request | headers] = String.split(top, "\n")

    [method, path, _] = String.split(request, " ")

    params = parse_params(body)

    %Conv{
      method: method,
      path: path,
      params: params
    }
  end

  def parse_params(params_string) do
    params_string |> String.trim |> URI.decode_query
  end
end
