defmodule AwesomeWeb.PageController do
  use AwesomeWeb, :controller

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    conn = Plug.Conn.fetch_query_params(conn)
    min_stars = conn.query_params["min_stars"] || "0"

    conn
    |> assign(:cats, Database.select_all(String.to_integer(min_stars)))
    |> assign(:stars, min_stars)
    |> render("index.html")
  end
end
