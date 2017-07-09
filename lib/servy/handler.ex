defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  alias Servy.Conv
  alias Servy.BearController

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  #
  # Routes
  #

  # wildthings
  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end
  # bears
  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end
  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    "../../pages"
    |> Path.expand(__DIR__)
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end
  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end
  def route(%Conv{ method: "DELETE", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end
  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/about" } = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end
  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    "../../pages"
    |> Path.expand(__DIR__)
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end
  # catch all route
  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{ path } here!"}
  end

  # File handler
  def handle_file({ :ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handle_file({ :error, :enoent }, conv) do
    %{ conv | status: 404, resp_body: "File not found!" }
  end

  def handle_file({ :error, reason }, conv) do
    %{ conv | status: 500, resp_body: "File error: #{ reason }"}
  end

  # Format HTTP Response
  def format_response(%Conv{} = conv) do
    # Use the values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{ byte_size(conv.resp_body) }\r
    \r
    #{ conv.resp_body }
    """
  end
end
