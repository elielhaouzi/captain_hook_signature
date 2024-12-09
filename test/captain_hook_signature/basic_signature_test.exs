defmodule CaptainHookSignature.BasicHmacSignatureTest do
  use ExUnit.Case
  doctest CaptainHookSignature.BasicHmacSignature

  alias CaptainHookSignature.BasicHmacSignature

  test "signs a payload correctly" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"

    signature = "4d6303bf8995fd8fe7e5711e6cbedea69beceb244e8705f6560e4dc9735e6673"

    assert ^signature = BasicHmacSignature.sign(payload, secret)
  end

  test "when encoding is base64, it signs a payload correctly" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"

    signature = "TWMDv4mV/Y/n5XEebL7eppvs6yROhwX2Vg5NyXNeZnM="

    assert ^signature = BasicHmacSignature.sign(payload, secret, encoding: :base64)
  end

  test "verifies the signature" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"
    header = "4d6303bf8995fd8fe7e5711e6cbedea69beceb244e8705f6560e4dc9735e6673"

    assert :ok = BasicHmacSignature.verify(header, payload, secret)

    assert {:error, "signature is incorrect"} =
             BasicHmacSignature.verify(header, "a-different-payload", secret)

    assert {:error, "signature is incorrect"} =
             BasicHmacSignature.verify(header, payload, "another-secret")

    assert {:error, "signature is incorrect"} = BasicHmacSignature.verify("", payload, secret)

    assert {:error, "signature is missing"} = BasicHmacSignature.verify(nil, payload, secret)
  end

  test "when encoding is base64 verifies the signature" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"
    header = "TWMDv4mV/Y/n5XEebL7eppvs6yROhwX2Vg5NyXNeZnM="

    assert :ok = BasicHmacSignature.verify(header, payload, secret, encoding: :base64)

    assert {:error, "signature is incorrect"} =
             BasicHmacSignature.verify(header, "a-different-payload", secret, encoding: :base64)

    assert {:error, "signature is incorrect"} =
             BasicHmacSignature.verify(header, payload, "another-secret", encoding: :base64)

    assert {:error, "signature is incorrect"} =
             BasicHmacSignature.verify("", payload, secret, encoding: :base64)

    assert {:error, "signature is missing"} =
             BasicHmacSignature.verify(nil, payload, secret, encoding: :base64)
  end
end
