defmodule Tbot.Redis do
  def start_link do
   {:ok, conn} = Redix.start_link(redis_host())
   conn
  end

  def set(conn, key, value) do
    Redix.command(conn, ["SET", key, value])
  end

  def get(conn, key) do
    {:ok, value} = Redix.command(conn, ["GET", key])
    value
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
