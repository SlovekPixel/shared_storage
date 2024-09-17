FROM elixir:1.17

WORKDIR /app

RUN apt-get update && \
    apt-get install -y postgresql-client

COPY . /app

# Install hex and rebar3
RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get

EXPOSE 4000

ENV MIX_ENV=dev

RUN mix compile

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && DATABASE_URL=ecto://postgres:postgres@ss_db/shared_storage_dev mix phx.server"]