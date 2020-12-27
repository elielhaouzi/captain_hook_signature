defmodule CaptainHookSignature.MixProject do
  use Mix.Project

  @source_url "https://github.com/annatel/captain_hook_signature"
  @version "0.3.0"

  def project do
    [
      app: :captain_hook_signature,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.2"},
      {:plug_crypto, "~> 1.1"}
    ]
  end

  defp description() do
    "CaptainHook signature. It follows the Stripe’s specification about signature."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
