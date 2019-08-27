defmodule AwesomeWeb.PageController do
  use AwesomeWeb, :controller

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    min_stars = conn.query_params["min_stars"] || "0"

    case Integer.parse(min_stars) do
      {i, _} ->
        conn
        |> assign(:cats, Database.select_all(i))
        |> assign(:stars, min_stars)
        |> render("index.html")

      _ ->
        conn
        |> put_status(400)
        |> assign(:cats, [])
        |> assign(:stars, min_stars)
        |> render("index.html")
    end
  end
end
