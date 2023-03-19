defmodule QuickAuction.FrontendWeb.LoginController do
  use QuickAuction.FrontendWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:form, %{})
    |> assign(:logged_in, false)
    |> render(:login)
  end

  def create(conn, %{"username" => user_name}) do
    user_id = Uniq.UUID.uuid4()
    name_suffix = String.split(user_id, "-") |> hd()
    suffixed_user_name = user_name <> "_" <> name_suffix

    Phoenix.PubSub.broadcast(
      QuickAuction.PubSub,
      "user_entered",
      {:user_entered, %{id: user_id, name: suffixed_user_name}}
    )

    conn
    |> put_session(:user_name, suffixed_user_name)
    |> put_session(:user_id, user_id)
    |> assign(:logged_in, true)
    |> redirect(to: ~p"/auctions")
  end

  def leave(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/login")
  end
end
