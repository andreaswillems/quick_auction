FROM elixir:1.14.3-slim
RUN apt-get update -y && apt-get install -y build-essential git nodejs npm curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY assets assets
COPY priv priv

COPY lib lib
RUN mix compile
RUN mix assets.deploy

COPY config/runtime.exs config/

ENV NODE_ONE="frontend1@OLOK-PO-265.local"
ENV NODE_TWO="frontend2@OLOK-PO-265.local"
ENV NODE_THREE="backend@OLOK-PO-265.local"
ENV COOKIE="secret"
ENV ADMIN_USER="admin"
ENV ADMIN_PASS="secret"
CMD ["/bin/bash", "-c", "iex --name ${NODE_ONE} --cookie ${COOKIE} -S mix phx.server"]