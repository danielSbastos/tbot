# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tbot,
  ecto_repos: [Tbot.Repo]

# Configures the endpoint
config :tbot, TbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZdwfCGwZ9BmuaYzCoHd/6ufdrfo4ABEoP7z8N34KogXf2qyZqFrt9mp+ZtQfj7fc",
  render_errors: [view: TbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
