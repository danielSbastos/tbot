defmodule Tbot.Redis do
  @moduledoc false
  def start_link do
   {:ok, conn} = Redix.start_link(redis_host())
   conn
  end

  def set(conn, key, value) do
    Redix.command(conn, ["SET", key, value])
  end

  def update(conn, key, value) do
    if Redix.command(conn, ["EXISTS", key]) == 1 do
      existing_value = Redix.command(conn, ["GET", key])
      list = existing_value ++ [value]
      Redix.command(conn, ["SET", key, list])
    end
  end

  def get(conn, key) do
    {:ok, value} = Redix.command(conn, ["GET", key])
    value
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
