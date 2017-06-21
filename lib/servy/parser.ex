defmodule Servy.Parser do

  alias Servy.Conv

  # Parse raw request into a map
  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    params = parse_params params_string

    %Conv{ 
      method: method, 
      path: path, 
      params: params
    }
  end

  @doc "Trims newline and converts query string to map"
  def parse_params(params_string) do
    params_string
      |> String.trim
      |> URI.decode_query
  end
end
