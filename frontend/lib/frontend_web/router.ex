defmodule QuickAuction.FrontendWeb.Router do
  use QuickAuction.FrontendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {QuickAuction.FrontendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :admin_auth
  end

  defp admin_auth(conn, _opts) do
    admin_user = Application.fetch_env!(:frontend, :admin_user)
    admin_pass = Application.fetch_env!(:frontend, :admin_pass)
    Plug.BasicAuth.basic_auth(conn, username: admin_user, password: admin_pass)
  end

  scope "/", QuickAuction.FrontendWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", LoginController, :index
    get "/logout", LoginController, :leave
    post "/login", LoginController, :create
    live "/auctions", AuctionsLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuickAuction.FrontendWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  # if Application.compile_env(:frontend, :dev_routes) do
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through :admin
    pipe_through :browser

    live_dashboard "/dashboard", metrics: QuickAuction.FrontendWeb.Telemetry
  end

  # end
end
