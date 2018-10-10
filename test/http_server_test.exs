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

  test "demonstrate message sending" do
    spawn(HttpServer, :start, [5000])
    parent = self()
    max_concurrent_requests = 5

    # Spawn processes that each send a request to HttpServer
    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        {:ok, response} = HTTPoison.get('http://localhost:5000/wildthings')
        send(parent, {:ok, response})
      end)
    end

    # Wait for each message from the spawned processes, and check that the
    # message includes a successful response.
    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
      end
    end
  end
end
