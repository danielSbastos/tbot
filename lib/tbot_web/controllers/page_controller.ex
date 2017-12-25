defmodule TbotWeb.PageController do
  use TbotWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
