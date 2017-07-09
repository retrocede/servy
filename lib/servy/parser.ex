defmodule Servy.Parser do

  alias Servy.Conv

  # Parse raw request into a map
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{ 
      method: method, 
      path: path, 
      params: params,
      headers: headers
    }
  end

  @doc "Converts headers to a map"
  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, &parse_headers/2)
  end
  def parse_headers(head, headers) do
    [key, value] = String.split(head, ": ")
    Map.put(headers, key, value)
  end

  @doc """
  Parses the given param string of the form `key1=value&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/forn-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
      |> String.trim
      |> URI.decode_query
  end
  def parse_params(_, _), do: %{}

end
