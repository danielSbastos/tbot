[![Codebeat](https://codebeat.co/badges/42c9fe03-e8ba-469e-8b14-3282f5361b83)](https://codebeat.co/projects/github-com-danielsbastos-tbot-master)
[![CircleCI](https://circleci.com/gh/danielSbastos/tbot/tree/master.svg?style=shield&circle-token=350e60ec92fa8686df6b34c07242545a7d7a1e15)](https://circleci.com/gh/danielSbastos/tbot/tree/master)


# Tbot

- [Dependencies](#dependencies)
- [Setup](#setup)
- [Development](#development)
- [Tests](#tests)
- [Code Quality](#code_quality)


## Dependencies

- PostgreSQL 9.6.1
- Elixir >= 1.5

## Setup

Create the following file to store tokens for development environments, `tbot/config/dev.secret.exs`, and add the contents below:

```ex
use Mix.Config

config :tbot,
  messenger_verify_token: "your_messenger_verify_token",
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

## Code Quality

Code lintage and quality analysis is done via [credo](https://github.com/rrrene/credo). To execute it, write the command below:

```sh
$ mix credo
```
