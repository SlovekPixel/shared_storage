FROM elixir:1.17

WORKDIR /app

RUN apt-get update

COPY . /app

# Install hex and rebar3
RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get

EXPOSE 4000

ENV MIX_ENV=dev

RUN mix compile

CMD ["sh", "-c", "mix setup && mix phx.server"]