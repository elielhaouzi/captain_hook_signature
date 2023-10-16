defmodule CaptainHookSignature.Plug.HTTPSignatureTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias CaptainHookSignature.Plug.HTTPSignature

  defmodule FakeSystem do
    def system_time(:second), do: 1_595_960_807
  end

  defp cache_raw_body(conn) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])

    put_in(conn.assigns[:raw_body], body)
  end

  test "when the payload according to the signature is authentic, returns the conn" do
    conn =
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> put_req_header(
        "signature",
        "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"
      )
      |> HTTPSignature.call(HTTPSignature.init(secret: "a-secret", system: FakeSystem))

    refute conn.halted
  end

  test "when the signature is missing, halt the conn with a 400 error" do
    conn =
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> HTTPSignature.call(HTTPSignature.init(secret: "a-secret", system: FakeSystem))

    assert conn.halted
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert {:ok, _} = Jason.decode(conn.resp_body)

    assert conn.resp_body ==
             "{\"errors\":{\"detail\":\"HTTP Signature is invalid: signature is not present in header \\\"signature\\\"\"}}"
  end

  test "when the raw_body is missing, raises a RawBodyNotPresentError exception" do
    assert_raise HTTPSignature.RawBodyNotPresentError, fn ->
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> put_req_header(
        "signature",
        "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"
      )
      |> HTTPSignature.call(HTTPSignature.init(secret: "a-secret", system: FakeSystem))
    end
  end

  test "when the secret is missing, halt the conn with a 400 error" do
    assert_raise KeyError, fn ->
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> put_req_header(
        "signature",
        "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"
      )
      |> HTTPSignature.call(HTTPSignature.init(system: FakeSystem))
    end
  end

  test "when the payload according to the signature is not authentic, halt the conn and returns 400 error" do
    conn =
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> put_req_header(
        "signature",
        "t=1595960507,v1=a-wrong-signature"
      )
      |> HTTPSignature.call(HTTPSignature.init(secret: "a-secret", system: FakeSystem))

    assert conn.halted
    assert conn.status == Plug.Conn.Status.code(:bad_request)

    assert conn.resp_body ==
             "{\"errors\":{\"detail\":\"HTTP Signature is invalid: signature is incorrect\"}}"
  end

  test "support secret to be a function/1" do
    secret = fn %Plug.Conn{} = _conn -> "a-secret" end

    conn =
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> put_req_header(
        "signature",
        "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"
      )
      |> HTTPSignature.call(HTTPSignature.init(secret: secret, system: FakeSystem))

    refute conn.halted
  end

  test "support another signature header name" do
    conn =
      conn(:post, "/", "{\"data\": \"a-sample-payload\"}")
      |> cache_raw_body()
      |> put_req_header(
        "signature",
        "t=1595960507,v1=10f65f2a9dfc9325b59109e7ee631ea11c419457f0b292299c770b137393b0ce"
      )
      |> HTTPSignature.call(
        HTTPSignature.init(
          secret: "a-secret",
          system: FakeSystem,
          signature_header_name: "signature"
        )
      )

    refute conn.halted
  end
end
