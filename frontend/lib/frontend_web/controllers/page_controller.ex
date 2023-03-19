defmodule QuickAuction.FrontendWeb.PageController do
  use QuickAuction.FrontendWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/login")
  end
end
