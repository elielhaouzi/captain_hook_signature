defmodule CaptainHookSignature.BasicHmacSignature do
  @moduledoc """
  `CaptainHookSignature.BasicHmacSignature`
  """

  @behaviour CaptainHookSignature.Behaviour

  @default_encoding :hex

  @spec sign(binary, binary) :: binary
  @spec sign(binary, binary, keyword) :: binary
  def sign(payload, secret, opts \\ []) when is_binary(payload) and is_binary(secret) do
    encoding = Keyword.get(opts, :encoding, @default_encoding)
    hash(payload, secret, encoding)
  end

  @spec verify(binary, binary, binary, keyword) :: :ok | {:error, binary}
  @spec verify(binary, binary, binary) :: :ok | {:error, binary}
  def verify(header, payload, secret, opts \\ []) do
    encoding = Keyword.get(opts, :encoding, @default_encoding)

    with {:ok, hash} <- parse_signature_header(header) do
      expected_hash = hash(payload, secret, encoding)

      if Plug.Crypto.secure_compare(hash, expected_hash) do
        :ok
      else
        {:error, "signature is incorrect"}
      end
    end
  end

  defp hash(payload, secret, encoding) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> encode(encoding)
  end

  defp encode(raw_hmac, @default_encoding), do: Base.encode16(raw_hmac, case: :lower)
  defp encode(raw_hmac, :base64), do: Base.encode64(raw_hmac)

  @spec parse_signature_header(binary) :: {:error, binary} | {:ok, hash :: binary}
  defp parse_signature_header(signature) when is_binary(signature), do: {:ok, signature}
  defp parse_signature_header(nil), do: {:error, "signature is missing"}
end
