# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :tbot, TbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZdwfCGwZ9BmuaYzCoHd/6ufdrfo4ABEoP7z8N34KogXf2qyZqFrt9mp+ZtQfj7fc",
  render_errors: [view: TbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tbot.PubSub,
           adapter: Phoenix.PubSub.PG2]


pool_size = fn () ->
  env_pool_size = System.get_env("REDIS_POOL_SIZE")
  pool_size = case env_pool_size do
    nil -> 50
    ""  -> 50
    _ -> Integer.parse(env_pool_size)
  end
end

config :tbot,
  redis_pool_size: pool_size.()

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
