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
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/
COPY products.json ./
COPY products_picsum.json ./

ENV NODE_ONE="backend@OLOK-PO-265.local"
ENV NODE_TWO="frontend1@OLOK-PO-265.local"
ENV NODE_THREE="frontend2@OLOK-PO-265.local"
ENV COOKIE="secret"
CMD ["/bin/bash", "-c", "iex --name ${NODE_ONE} --cookie ${COOKIE} -S mix run --no-halt"]