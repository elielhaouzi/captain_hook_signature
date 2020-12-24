import Config

if Mix.env() == :test do
  config :plug, :validate_header_keys_during_test, false
end
