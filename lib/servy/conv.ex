defmodule Servy.Conv do
    defstruct method: "", 
              path: "", 
              resp_body: "", 
              status: nil,
              params: %{},
              headers: %{},
              resp_content_type: "text/html"

    def full_status(conv) do
        "#{conv.status} #{status_reason(conv.status)}"
    end

    # helper function to map status codes to their message
    defp status_reason(code) do
      %{
        200 => "OK",
        201 => "Created",
        204 => "No Content",
        401 => "Unauthorized",
        403 => "Forbidden",
        404 => "Not Found",
        500 => "Internal Server Error"
        }[code]
      end
end