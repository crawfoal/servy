defmodule HandlerTest do
  use ExUnit.Case, async: true

  import Servy.Handler, only: [handle: 1]
  alias Servy.FourOhFourCounter

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Length: 20\r
    Content-Type: text/html\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "GET /bears" do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 356\r
    Content-Type: text/html\r
    \r
    <h1>All The Bears!</h1>

    <ul>
      <li>Brutus - Grizzly</li>
      <li>Iceman - Polar</li>
      <li>Kenai - Grizzly</li>
      <li>Paddington - Brown</li>
      <li>Roscoe - Panda</li>
      <li>Rosie - Black</li>
      <li>Scarface - Grizzly</li>
      <li>Smokey - Black</li>
      <li>Snow - Polar</li>
      <li>Teddy - Brown</li>
    </ul>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /bigfoot" do
    FourOhFourCounter.start
    request = """
    GET /bigfoot HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 404 Not Found\r
    Content-Length: 17\r
    Content-Type: text/html\r
    \r
    No /bigfoot here!
    """
    assert FourOhFourCounter.get_count("/bigfoot") == 1
    FourOhFourCounter.stop
  end

  test "GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 77\r
    Content-Type: text/html\r
    \r
    <h1>Show Bear</h1>
    <p>
    Is Teddy hibernating? <strong>true</strong>
    </p>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Length: 20\r
    Content-Type: text/html\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "GET /about" do
    request = """
    GET /about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 102\r
    Content-Type: text/html\r
    \r
    <h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe...
    </blockquote>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /faq" do
    request = """
    GET /faq HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 571\r
    Content-Type: text/html\r
    \r
    <h1>Frequently Asked Questions</h1>
    <ul>
    <li>
      <p><strong>Have you really seen Bigfoot?</strong></p>
      <p>
        Yes! In this <a href="https://www.youtube.com/watch?v=v77ijOO8oAk">
        totally believable video</a>!
       </p>
    </li>
    <li>
      <p><strong>No, I mean seen Bigfoot <em>on the refuge</em>?</strong></p>
      <p>Oh! Not yet, but we’re still looking…</p>
    </li>
    <li>
      <p><strong>Can you just show me some code?</strong></p>
      <p>
        Sure! Here’s some Elixir:
      </p>
    </li>
    </ul>
    <pre>
      <codeclass="elixir">
      [&quot;Bigfoot&quot;,&quot;Yeti&quot;,&quot;Sasquatch&quot;]|&gt;
      Enum.random()
      </code>
    </pre>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Length: 21\r
    Content-Type: application/x-www-form-urlencoded\r
    \r
    name=Baloo&type=Brown
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 201 Created\r
    Content-Length: 33\r
    Content-Type: text/html\r
    \r
    Created a Brown bear named Baloo!
    """
  end

  test "DELETE /bears/1" do
    request = """
    DELETE /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: */*\r
    \r
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Length: 14\r
    Content-Type: text/html\r
    \r
    Bear 1 deleted
    """
  end

  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 605\r
    Content-Type: application/json\r
    \r
    [{"type":"Brown","name":"Teddy","id":1,"hibernating":true},
     {"type":"Black","name":"Smokey","id":2,"hibernating":false},
     {"type":"Brown","name":"Paddington","id":3,"hibernating":false},
     {"type":"Grizzly","name":"Scarface","id":4,"hibernating":true},
     {"type":"Polar","name":"Snow","id":5,"hibernating":false},
     {"type":"Grizzly","name":"Brutus","id":6,"hibernating":false},
     {"type":"Black","name":"Rosie","id":7,"hibernating":true},
     {"type":"Panda","name":"Roscoe","id":8,"hibernating":false},
     {"type":"Polar","name":"Iceman","id":9,"hibernating":true},
     {"type":"Grizzly","name":"Kenai","id":10,"hibernating":false}]
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /api/bears" do
    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Length: 21\r
    Content-Type: application/json\r
    \r
    {"name": "Breezly", "type": "Polar"}
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 201 Created\r
    Content-Length: 35\r
    Content-Type: text/html\r
    \r
    Created a Polar bear named Breezly!
    """
  end

  test "GET /snapshots" do
    request = """
    GET /snapshots HTTP/1.1\r
    Host: example.com\r
    UserAgent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 303\r
    Content-Type: text/html\r
    \r
    <h1>Sensors</h1>
    <h2>Snapshots</h2>
    <ul>
      <li><imgsrc=\"cam-1-snapshot.jpg\"alt=\"snapshot\"></li>
      <li><imgsrc=\"cam-2-snapshot.jpg\"alt=\"snapshot\"></li>
      <li><imgsrc=\"cam-3-snapshot.jpg\"alt=\"snapshot\"></li>
    </ul>
    <h2>WhereIsBigfoot?</h2>
    %{lat:\"29.0469N\",lng:\"98.8667W\"}\n
    """
    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /pledges" do
    Servy.PledgeServer.start
    Servy.PledgeServer.create_pledge("Lucas", 10)
    Servy.PledgeServer.create_pledge("May", 20)
    Servy.PledgeServer.create_pledge("Ned", 30)
    request = """
    GET /pledges HTTP/1.1\r
    Host: example.com\r
    UserAgent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert String.contains?(response, "Recent Pledges")
    assert String.contains?(response, "Lucas: $10")
    assert String.contains?(response, "May: $20")
    assert String.contains?(response, "Ned: $30")

    Servy.PledgeServer.stop
  end

  test "GET /pledges/new" do
    request = """
    GET /pledges/new HTTP/1.1\r
    Host: example.com\r
    UserAgent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 304\r
    Content-Type: text/html\r
    \r
    <h1>Make a Pledge!</h1>
    <form action="/pledges" method="POST">
      <p>
        Name:<br/>
        <input type="text" name="name" placeholder="">
      </p>
      <p>
        Amount:<br/>
        <input type="number" name="amount" min="1" placeholder="">
      </p>
      <p>
        <inputtype=\"submit\"value=\"SubmitPledge\">
      </p>
    </form>\n
    """
    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
