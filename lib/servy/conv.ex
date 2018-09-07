defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_headers: %{ 
              "Content-Type" => "text/html",
              "Content-Length" => 0
            },
            resp_body: "",
            status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  def headers_to_s(conv) do
    conv = update_content_length(conv) # can remove when conversion is complete
    (conv.resp_headers
      |> Enum.into([], fn {k, v} -> "#{k}: #{v}" end)
      |> Enum.sort(&(&1 < &2))
      |> Enum.join("\r\n")) <> "\r"
  end

  def set_header(conv, name, value) do
    %{ conv | resp_headers: %{ conv.resp_headers | name => value } }
  end

  def set_status(conv, code) do
    %{ conv | status: code }
  end

  def set_body(conv, body) do
    %{ conv | resp_body: body } |> update_content_length
  end

  def update_content_length(conv) do
    conv |> set_header("Content-Length", String.length(conv.resp_body))
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end
