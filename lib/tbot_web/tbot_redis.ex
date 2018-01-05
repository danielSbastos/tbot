defmodule Tbot.Redis do
  @moduledoc false
  def start_link do
   {:ok, conn} = Redix.start_link(redis_host())
   conn
  end

  def set(conn, name, key, value) do
    Redix.command(conn, ["HSET", name, key, value])
  end

  def get_members(conn, name) do
    {:ok, value} = Redix.command(conn, ["HGETALL", name])
    value
  end

  def get_key_value(conn, name, key) do
    {:ok, value} = Redix.command(conn, ["HGET", name, key])
    value
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
