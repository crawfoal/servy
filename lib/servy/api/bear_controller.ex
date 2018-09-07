defmodule Servy.Api.BearController do
  alias Servy.Wildthings
  alias Servy.RespHeaders
  alias Servy.Conv

  def index(conv) do
    content = Wildthings.list_bears |> Poison.encode!

    conv
      |> Conv.set_status(200)
      |> Conv.set_body(content)
      |> Conv.set_header("Content-Type", "application/json")
  end
end
