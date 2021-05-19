# CaptainHookSignature

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/annatel/captain_hook_signature/CI?cacheSeconds=3600&style=flat-square)](https://github.com/annatel/captain_hook_signature/actions) [![GitHub issues](https://img.shields.io/github/issues-raw/annatel/captain_hook_signature?style=flat-square&cacheSeconds=3600)](https://github.com/annatel/captain_hook_signature/issues) [![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?cacheSeconds=3600?style=flat-square)](http://opensource.org/licenses/MIT) [![Hex.pm](https://img.shields.io/hexpm/v/captain_hook_signature?style=flat-square)](https://hex.pm/packages/captain_hook_signature) [![Hex.pm](https://img.shields.io/hexpm/dt/captain_hook_signature?style=flat-square)](https://hex.pm/packages/captain_hook_signature)

`CaptainHookSignature` follow the [Stripe's specification](https://stripe.com/docs/webhooks/signatures#verify-manually) for signing requests.
The code is based on [bytepack](https://github.com/dashbitco/bytepack_archive) from dashbitco.

[`CaptainHook`](https://github.com/annatel/captain_hook) use `CaptainHookSignature` to sign its requests.

## Installation

The package can be installed by adding `captain_hook_signature` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:captain_hook_signature, "~> 0.4.1"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/captain_hook_signature](https://hexdocs.pm/captain_hook_signature).

