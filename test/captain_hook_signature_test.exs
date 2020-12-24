defmodule CaptainHookSignatureTest do
  use ExUnit.Case
  doctest CaptainHookSignature

  test "signs a payload correctly" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"
    timestamp = 1_595_960_507

    signature = "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"

    assert ^signature = CaptainHookSignature.sign(payload, timestamp, secret)
  end

  defmodule FakeSystem do
    def system_time(:second), do: 1_595_960_807
  end

  test "verifies the signature" do
    payload = "{\"data\": \"a-sample-payload\"}"
    secret = "a-secret"
    header = "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"

    assert :ok = CaptainHookSignature.verify(header, payload, secret, system: FakeSystem)

    assert {:error, "signature is incorrect"} =
             CaptainHookSignature.verify(header, "a-different-payload", secret, system: FakeSystem)

    assert {:error, "signature is incorrect"} =
             CaptainHookSignature.verify(header, payload, "another-secret", system: FakeSystem)

    header = "t=1595950507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"

    assert {:error, "signature is too old"} =
             CaptainHookSignature.verify(header, payload, secret, system: FakeSystem)

    header = "t=1595960507,v2=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"

    assert {:error, "signature is in a wrong format or is missing v1 schema"} =
             CaptainHookSignature.verify(header, payload, secret, system: FakeSystem)

    header = "rubbish"

    assert {:error, "signature is in a wrong format or is missing v1 schema"} =
             CaptainHookSignature.verify(header, payload, secret, system: FakeSystem)
  end
end
