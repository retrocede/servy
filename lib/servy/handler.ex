defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  alias Servy.Conv

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
    |> emojify
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
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end
  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    "../../pages"
    |> Path.expand(__DIR__)
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end
  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "Bear #{ id }" }
  end
  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id } = conv) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!" }
  end
  # name=Baloo&type=Brown
  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    %{ conv | status: 201, resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}."}
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

  # Emojify: Add emojis to worthy responses
  def emojify(%Conv{ status: 200 } = conv) do
    emoji_bod = String.duplicate(" ☜(⌒▽⌒)☞ ", 3) <> "\n"
    <> conv.resp_body <> "\n"
    <> String.duplicate(" (｡◕‿◕｡) ", 3)
    %{ conv | resp_body: emoji_bod}
  end
  # catch all, not worthy of emoji splendor
  def emojify(%Conv{} = conv), do: conv


  # Format HTTP Response
  def format_response(%Conv{} = conv) do
    # Use the values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{ byte_size(conv.resp_body) }

    #{ conv.resp_body }
    """
  end
end

#
# Test Runs
#

# Sample req 1
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 2
request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 3
request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 4
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 5
request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 6
request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 7
request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 8
request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 9
request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle request

IO.puts response

# Sample req 10
request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response
