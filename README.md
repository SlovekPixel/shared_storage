# SharedStorage
A standalone service based on redis to provide 
fast ttl-driven data storage over grpc.

## Start
To start your Phoenix server:
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Visit [`localhost:4000`](http://localhost:4000).

## Proto
#### Generate proto files.
``` bash
protoc --elixir_out=gen_descriptors=true,plugins=grpc:. "./lib/protos/shared_storage.proto"
```
``` bash
mix protobuf.generate --output-path=./lib --include-path=./lib/protos shared_storage.proto
```

## Docker
#### Assemble the whole project:
``` bash
$ docker-compose up --build
```
#### Start only PG Database with docker:
``` bash
$ chmod +x docker_postgres_start.sh && ./docker_postgres_start.sh
```

## Additional commands for Elixir + Phoenix
``` bash
# Load and install dependencies specified in the "mix.exs".
$ mix deps.get

# Create the database specified in the Ecto configuration file.
$ mix ecto.create

# Applies all migrations to the database.
$ mix ecto.migrate

# Rolls back the last migration, returning the database to its previous state.
$ mix ecto.rollback

# Starts the Phoenix web server.
$ mix phx.server

# Runs tests.
$ mix test

# Preparing the database for tests.
$ MIX_ENV=test mix ecto.drop
$ MIX_ENV=test mix ecto.create
$ MIX_ENV=test mix ecto.migrate
```
