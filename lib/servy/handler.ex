defmodule Servy.Handler do
    def handle(request) do
        request
        |> parse
        |> log
        |> route
        |> format_response
    end

    def log(conv), do: IO.inspect conv

    def parse(request) do
        # Parse the request string into the map
        [ method, path, _] =
            request
            |> String.split("\n")
            |> List.first
            |> String.split(" ")

        %{ method: method, path: path, resp_body: "", status: nil}
    end

    #
    # Routes
    #

    # wildthings
    def route(%{ method: "GET", path: "/wildthings" } = conv), do: %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
    # bears
    def route(%{ method: "GET", path: "/bears" } = conv), do: %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
    def route(%{ method: "GET", path: "/bears/" <> id } = conv), do: %{ conv | status: 200, resp_body: "Bear #{ id }" }
    # catch all route
    def route(%{ method: _method, path: path } = conv), do: %{ conv | status: 404, resp_body: "No #{ path } here!"}

    def format_response(conv) do
        # Use the values in the map to create an HTTP response string:
        """
        HTTP/1.1 #{ conv.status } #{ status_reason conv.status }
        Content-Type: text/html
        Content-Length: #{ byte_size(conv.resp_body) }

        #{ conv.resp_body }
        """
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
