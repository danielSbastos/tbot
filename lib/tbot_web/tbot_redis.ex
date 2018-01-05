defmodule Tbot.Redis do
  @moduledoc false
  def start_link do
   {:ok, conn} = Redix.start_link(redis_host())
   conn
  end

  def set(conn, key, value) do
    Redix.command(conn, ["SADD", key, value])
  end

  def get_members(conn, key) do
    {:ok, value} = Redix.command(conn, ["SMEMBERS", key])
    value
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
