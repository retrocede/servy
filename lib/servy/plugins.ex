defmodule Servy.Plugins do
  @moduledoc """
  Yolo
  """
  require Logger

  alias Servy.Conv

  @doc "Logs 404 requests"
  def track(%Conv{ status: 404, path: path } = conv) do
    if Mix.env != :test do
      Logger.error "Error 404: #{ path } not found."
    end
    conv
  end
  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{ path: "/wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{ path: path } = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end
  # catch all, rewrite not needed
  def rewrite_path(%Conv{} = conv), do: conv

  # helper to rewrite thing?id=# routes
  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{ thing }/#{ id }" }
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  @doc "Generic logger"
  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      Logger.info inspect conv
    end
    conv
  end
end
