defmodule QuickAuction.FrontendWeb.Presence do
  use Phoenix.Presence, otp_app: :tutorial, pubsub_server: QuickAuction.PubSub
end
