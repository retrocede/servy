defmodule Servy.Plugins do
  require Logger

  @doc "Logs 404 requests"
  def track(%{ status: 404, path: path } = conv) do
    Logger.error "Error 404: #{ path } not found."
    conv
  end
  def track(conv), do: conv

  def rewrite_path(%{ path: "/wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%{ path: path } = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end
  # catch all, rewrite not needed
  def rewrite_path(conv), do: conv

  # helper to rewrite thing?id=# routes
  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{ thing }/#{ id }" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  @doc "Generic logger"
  def log(conv) do
    Logger.info inspect conv
    conv
  end
end
