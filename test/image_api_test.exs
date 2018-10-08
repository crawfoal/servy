defmodule ImageApiTest do
  use ExUnit.Case, async: true

  alias Servy.ImageApi

  test "query success" do
    image_url = case ImageApi.query("16x3i5") do
      {:ok, image_url} ->
        image_url
      {:error, error} ->
        "Whoops! #{error}"
    end

    assert image_url == "https://images.example.com/bear.jpg"
  end

  test "query failure" do
    message = case ImageApi.query("not_found") do
      {:ok, image_url} ->
        image_url
      {:error, error} ->
        "Whoops! #{error}"
    end

    assert message == "Whoops! Internal Server Error"
  end
end
