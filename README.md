# Tbot

### Bot written in Elixir with Phantom as a framework for learning purposes

- [Dependencies](#dependencies)
- [Setup](#setup)
- [Development](#development)
- [Tests](#tests)


## Dependencies

- PostgreSQL 9.6.1
- Elixir >= 1.5

## Setup

```sh
$ cp .env.example .env
```

Install hex package manager and rebar, install missing dependencies and create the storage for the repo

```
$ mix local.hex --force
$ mix local.rebar
$ mix deps.get
$ mix ecto.create
```

# Developemnt

**Note:** before executing any command that uses the environment variables in development mode, the following command must be executed:

```sh
$ touch .env
```

To start the server:

```sh
$ mix phx.server
```

# Tests

```sh
$ mix test
```
