defmodule Servy.ImageApi do
  @base_url "https://api.myjson.com/bins/"

  def query(image_name) do
    HTTPoison.get("#{@base_url}#{image_name}") |> extract_path
  end

  defp extract_path({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body) |> get_in(["image", "image_url"])}
  end

  defp extract_path({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, Poison.Parser.parse!(body) |> Map.get("message")}
  end

  defp extract_path({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
