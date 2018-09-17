defmodule Servy.HttpClient do
  def client(port) do
    some_host_in_net = 'localhost'
    {:ok, sock} = :gen_tcp.connect(some_host_in_net, port,
                                   [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """)
    {:ok, packet} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    IO.puts packet
  end
end
