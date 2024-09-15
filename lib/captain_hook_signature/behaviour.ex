defmodule CaptainHookSignature.Behaviour do
  @moduledoc """
  Behaviour for signature verification
  """

  @callback sign(payload :: binary(), secret :: binary()) :: binary()
  @callback sign(payload :: binary(), secret :: binary(), opts :: keyword()) :: binary()
  @optional_callbacks sign: 3

  @callback verify(header :: binary(), payload :: binary(), secret :: binary()) ::
              :ok | {:error, binary()}
  @callback verify(header :: binary(), payload :: binary(), secret :: binary(), opts :: keyword()) ::
              :ok | {:error, binary()}
  @optional_callbacks verify: 4
end
