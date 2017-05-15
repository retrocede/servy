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

        %{ method: method, path: path, resp_body: "" }
    end

    def route(%{ method: "GET", path: "/wildthings" } = conv), do: %{ conv | resp_body: "Bears, Lions, Tigers"}
    def route(%{ method: "GET", path: "/bears" } = conv), do: %{ conv | resp_body: "Teddy, Smokey, Paddington"}

    def format_response(conv) do
        # Use the values in the map to create an HTTP response string:
        """
        HTTP/1.1 200 OK
        Content-Type: text/html
        Content-Length: #{ byte_size(conv.resp_body) }

        #{ conv.resp_body }
        """
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
