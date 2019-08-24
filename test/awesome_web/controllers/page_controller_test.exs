defmodule AwesomeWeb.PageControllerTest do
  use AwesomeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Awesome Elixir"
  end
end
