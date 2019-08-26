FROM elixir:alpine as build

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# build assets
COPY assets assets
COPY static.sh static.sh
RUN ./static.sh
RUN mix phx.digest

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/awesome ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

CMD bin/awesome eval "Awesome.Release.migrate" ; bin/awesome start
