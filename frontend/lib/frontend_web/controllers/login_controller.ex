defmodule QuickAuction.FrontendWeb.LoginController do
  use QuickAuction.FrontendWeb, :controller

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # render(conn, :login, layout: false)

    conn
    |> assign(:form, %{})
    |> render(:login)
  end

  def create(conn, %{"username" => username}) do
    conn
    |> put_session(:user_name, username)
    |> put_session(:user_id, UUID.uuid4())
    |> redirect(to: ~p"/auctions")
  end
end
