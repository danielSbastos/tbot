defmodule TbotWeb.Router do
  use TbotWeb, :router

  pipeline :messenger do
    plug :accepts, ["json"]
  end

  scope "/", TbotWeb do
    pipe_through :messenger

    get "/bot", TbotController, :challenge
  end
end
