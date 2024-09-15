defmodule CaptainHookSignature.StripeSignature do
  @moduledoc """
  Verifies the request body in order to ensure that its signature is valid.
  This verification can avoid someone to send a request on behalf of our client.

  So the client must send a header with the following structure:
      t=timestamp-in-seconds,
      v1=signature

  Where the `timestamp-in-seconds` is the system time in seconds, and `signature`
  is the HMAC using the SHA256 algorithm of timestamp and the payload, signed by
  a shared secret with us.

  This is based on what Stripe is doing: https://stripe.com/docs/webhooks/signatures
  """
  @behaviour CaptainHookSignature.Behaviour

  @schema "v1"
  @default_valid_period_in_seconds 5 * 60

  @spec sign(binary, binary | [binary], keyword) :: binary
  @spec sign(binary, binary | [binary]) :: binary
  def sign(payload, secret, opts \\ []) when is_binary(payload) do
    timestamp = Keyword.fetch!(opts, :timestamp)

    signature = "t=#{timestamp},"

    secret
    |> List.wrap()
    |> Enum.reduce(signature, fn secret, acc ->
      acc <> "#{@schema}=#{hash(payload, timestamp, secret)},"
    end)
    |> String.trim(",")
  end

  @spec verify(binary, binary, binary, keyword) :: :ok | {:error, binary}
  @spec verify(binary, binary, binary) :: :ok | {:error, binary}
  def verify(header, payload, secret, opts \\ []) do
    with {:ok, timestamp, hashes} <- parse_signature_header(header, @schema) do
      valid_period_in_seconds =
        Keyword.get(opts, :valid_period_in_seconds, @default_valid_period_in_seconds)

      current_timestamp = Keyword.get(opts, :system, System).system_time(:second)
      expected_hash = hash(payload, timestamp, secret)

      cond do
        timestamp + valid_period_in_seconds < current_timestamp ->
          {:error, "signature is too old"}

        Enum.all?(hashes, &(Plug.Crypto.secure_compare(&1, expected_hash) == false)) ->
          {:error, "signature is incorrect"}

        true ->
          :ok
      end
    end
  end

  defp hash(payload, timestamp, secret) do
    :crypto.mac(:hmac, :sha256, secret, "#{timestamp}.#{payload}")
    |> Base.encode16(case: :lower)
  end

  @spec parse_signature_header(binary, binary) ::
          {:error, binary} | {:ok, timestamp :: integer, hashes :: [binary]}
  defp parse_signature_header(signature, schema) do
    parsed =
      for pair <- String.split(signature, ","),
          destructure([key, value], String.split(pair, "=", parts: 2)),
          do: {key, value},
          into: []

    with [{"t", timestamp} | hashes] <- parsed,
         {timestamp, ""} <- Integer.parse(timestamp),
         {^schema, _} <- hashes |> List.first() do
      hashes =
        hashes
        |> Enum.filter(fn {key, _value} -> key == schema end)
        |> Enum.map(fn {_key, value} -> value end)

      {:ok, timestamp, hashes}
    else
      _ -> {:error, "signature is in a wrong format or is missing v1 schema"}
    end
  end
end
