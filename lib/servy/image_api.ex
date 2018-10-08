defmodule Servy.ImageApi do
  @base_url "https://api.myjson.com/bins/"

  def query(image_name) do
    case HTTPoison.get "#{@base_url}#{image_name}" do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.Parser.parse!(body) |> get_in(["image", "image_url"])}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, Poison.Parser.parse!(body) |> Map.get("message")}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
