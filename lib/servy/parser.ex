defmodule Servy.Parser do

  alias Servy.Conv

  # Parse raw request into a map
  def parse(request) do
    # Parse the request string into the map
    [ method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %Conv{ method: method, path: path, resp_body: "", status: nil}
  end
end
