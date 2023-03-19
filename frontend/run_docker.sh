docker run --rm -it -p 4000:4000 \
  -e SECRET_KEY_BASE=$(mix phx.gen.secret) \
  -e PHX_HOST=quickauction.andreaswillems.dev \
  -e RELEASE_COOKIE=thisissecret \
  -e NODE_ONE=frontend1@OLOK-PO-265.local \
  -e NODE_TWO=frontend2@OLOK-PO-265.local \
  -e NODE_THREE=backend@OLOK-PO-265.local \
  quick_auction_frontend:0.1