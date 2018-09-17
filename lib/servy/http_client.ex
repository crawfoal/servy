defmodule Servy.HttpClient do
  @doc ~S"""
  ## Examples

      iex> Servy.HttpClient.send_request("GET /bears HTTP/1.1\r\nHost: example.com\r\nUser-Agent: ExampleBrowser/1.0\r\nAccept: */*\r\n\r\n")
      <h1>AllTheBears!</h1><ul><li>Brutus-Grizzly</li><li>Iceman-Polar</li><li>Kenai-Grizzly</li><li>Paddington-Brown</li><li>Roscoe-Panda</li><li>Rosie-Black</li><li>Scarface-Grizzly</li><li>Smokey-Black</li><li>Snow-Polar</li><li>Teddy-Brown</li></ul>
  """
  def send_request(request) do
    some_host_in_net = 'localhost'
    {:ok, sock} = :gen_tcp.connect(some_host_in_net, 4000,
                                   [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, request)
    {:ok, packet} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    IO.puts packet
  end
end
