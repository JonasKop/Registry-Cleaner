FROM elixir:1.10.3-alpine AS build-stage
WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    apk --no-cache add build-base

COPY mix.exs mix.lock ./

RUN mix deps.get --only prod && \
    mix deps.compile

COPY config ./config

COPY lib ./lib

RUN mix release registry_cleaner 

FROM alpine:3.11 AS prod-stage
WORKDIR /app

RUN apk --no-cache add openssl ncurses-dev

COPY --from=build-stage /app/_build .

CMD ["/app/prod/rel/registry_cleaner/bin/registry_cleaner", "start"]
