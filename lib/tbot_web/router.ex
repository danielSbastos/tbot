defmodule TbotWeb.Router do
  use TbotWeb, :router

  pipeline :messenger do
    plug :accepts, ["json"]
  end

  scope "/", TbotWeb do
    pipe_through :messenger

    get "/bot", TbotController, :challenge
    post "/bot", TbotController, :webhook
  end
end
