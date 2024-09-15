defmodule CaptainHookSignature.BasicHmacSignature do
  @moduledoc """
  `CaptainHookSignature.BasicHmacSignature`
  """

  @behaviour CaptainHookSignature.Behaviour

  @spec sign(binary, binary) :: binary
  def sign(payload, secret) when is_binary(payload) and is_binary(secret) do
    hash(payload, secret)
  end

  @spec verify(binary, binary, binary, keyword) :: :ok | {:error, binary}
  @spec verify(binary, binary, binary) :: :ok | {:error, binary}
  def verify(header, payload, secret, _opts \\ []) do
    with {:ok, hash} <- parse_signature_header(header) do
      expected_hash = hash(payload, secret)

      if Plug.Crypto.secure_compare(hash, expected_hash) do
        :ok
      else
        {:error, "signature is incorrect"}
      end
    end
  end

  defp hash(payload, secret) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end

  @spec parse_signature_header(binary) :: {:error, binary} | {:ok, hash :: binary}
  defp parse_signature_header(signature) when is_binary(signature), do: {:ok, signature}
  defp parse_signature_header(nil), do: {:error, "signature is missing"}
end
