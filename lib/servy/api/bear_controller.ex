defmodule Servy.Api.BearController do
  alias Servy.Wildthings
  alias Servy.Conv

  def index(conv) do
    content = Wildthings.list_bears |> Poison.encode!

    conv
      |> Conv.set_status(200)
      |> Conv.set_body(content)
      |> Conv.set_header("Content-Type", "application/json")
  end

  def create(conv) do
    bear = conv.params |> Wildthings.create_bear

    conv
      |> Conv.set_status(201)
      |> Conv.set_body("Created a Polar bear named #{bear.name}!")
  end
end
