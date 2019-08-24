defmodule AwesomeWeb.Router do
  use AwesomeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_query_params
  end

  scope "/", AwesomeWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
