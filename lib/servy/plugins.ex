defmodule Servy.Plugins do

  alias Servy.Conv
  alias Servy.FourOhFourCounter

  @doc """
  Logs 404 requests
  """
  def track(%Conv{ status: 404, path: path } = conv) do
    FourOhFourCounter.bump_count(path)
    conv
  end
  def track(%Conv{} = conv) do
    conv
  end

  def rewrite_path(%Conv{ path: "/bears?id=" <> id } = conv) do
    %{ conv | path: "/bears/#{id}" }
  end
  def rewrite_path(%Conv{ path: "/wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end
  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end
end
