use Mix.Config

config :tbot,
  messenger_verify_token: "blabla",
  messenger_page_token: "blabla",
  yandex_api_key: "blabla",
  wordnik_api_key: "blabla",
  redis_host: "redis://localhost:6379/3"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tbot, TbotWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
