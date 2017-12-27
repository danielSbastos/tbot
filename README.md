# Tbot

- [Dependencies](#dependencies)
- [Setup](#setup)
- [Development](#development)
- [Tests](#tests)


## Dependencies

- PostgreSQL 9.6.1
- Elixir >= 1.5

## Setup

Create the following file to store tokens for development environments, `tbot/config/dev.secret.exs`, and add the contents below:

```ex
use Mix.Config

config :tbot,
  messenger_verify_token: "your_messenger_verify_token",
  messenger_app_id: "your_messenger_app_id",
  messenger_page_token: "your_messenger_page_token"
```

Install hex package manager and rebar, install missing dependencies and create the storage for the repo

```
$ mix local.hex --force
$ mix local.rebar
$ mix deps.get
$ mix ecto.create
```

## Developemnt

To start the server:

```sh
$ mix phx.server
```

## Tests

```sh
$ mix test
```
