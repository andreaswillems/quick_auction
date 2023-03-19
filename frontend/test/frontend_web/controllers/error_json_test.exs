defmodule QuickAuction.FrontendWeb.ErrorJSONTest do
  use QuickAuction.FrontendWeb.ConnCase, async: true

  test "renders 404" do
    assert QuickAuction.FrontendWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert QuickAuction.FrontendWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
