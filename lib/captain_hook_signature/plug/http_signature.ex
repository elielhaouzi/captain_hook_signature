# Based on:
# https://github.com/dashbitco/bytepack_archive/blob/main/apps/bytepack_web/lib/bytepack_web/controllers/webhooks/http_signature.ex
defmodule CaptainHookSignature.Plug.HTTPSignature do
  @moduledoc """
  `CaptainHookSignature.Plug.HTTPSignature`.
  """
  defmodule RawBodyNotPresentError do
    defexception message: "raw body is not available"
  end

  import Plug.Conn

  @behaviour Plug
  @signature_header_name "signature"

  @impl true
  @spec init(keyword) :: keyword
  def init(opts) do
    Keyword.fetch!(opts, :module)
    Keyword.fetch!(opts, :secret)

    opts
  end

  @impl true
  @spec call(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def call(conn, opts) do
    module = Keyword.fetch!(opts, :module)
    signature_header_name = Keyword.get(opts, :signature_header_name, @signature_header_name)

    with {:ok, header} <- signature_header(conn, signature_header_name),
         {:ok, body} <- raw_body(conn),
         :ok <- module.verify(header, body, fetch_secret!(conn, opts), opts) do
      conn
    else
      {:error, error} ->
        conn
        |> put_status(:bad_request)
        |> put_resp_content_type("application/json")
        |> send_resp(
          Plug.Conn.Status.code(:bad_request),
          Jason.encode!(%{errors: %{detail: "HTTP Signature is invalid: #{error}"}})
        )
        |> halt()
    end
  end

  defp signature_header(conn, header_name) do
    case get_req_header(conn, header_name) do
      [header] when is_binary(header) ->
        {:ok, header}

      _ ->
        {:error, "signature is not present in header #{inspect(header_name)}"}
    end
  end

  defp raw_body(conn) do
    case conn do
      %Plug.Conn{assigns: %{raw_body: raw_body}} ->
        {:ok, IO.iodata_to_binary(raw_body)}

      _ ->
        raise RawBodyNotPresentError
    end
  end

  defp fetch_secret!(conn, opts) do
    opts
    |> Keyword.fetch!(:secret)
    |> case do
      secret when is_binary(secret) -> secret
      secret when is_function(secret, 1) -> secret.(conn)
    end
  end
end
