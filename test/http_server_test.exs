defmodule HttpServerTest do
  use ExUnit.Case, async: true

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "GET /wildthings" do
    spawn(HttpServer, :start, [4000])

    {:ok, response} = HTTPoison.get('http://localhost:4000/wildthings')

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end

  test "smoke test some routes" do
    spawn(HttpServer, :start, [5000])

    [
      'http://localhost:5000/wildthings',
      'http://localhost:5000/about',
      'http://localhost:5000/bears'
    ]
    |> Enum.map(&Task.async(HTTPoison, :get, [&1]))
    |> Enum.map(&Task.await/1)
    |> Enum.each(fn({:ok, response}) -> assert response.status_code == 200 end)
  end
end
