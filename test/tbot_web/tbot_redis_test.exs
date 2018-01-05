defmodule Tbot.RedisTest do
  use TbotWeb.ConnCase

  alias Tbot.Redis, as: Redis

  setup_all do
    {:ok, conn} = Redix.start_link(redis_host())
    Redix.command!(conn, ["FLUSHDB"])
    Redix.stop(conn)
    :ok
  end

  setup context do
    if context[:no_setup] do
      {:ok, %{}}
    else
      {:ok, conn} = Redix.start_link(redis_host())
      {:ok, %{conn: conn}}
    end
  end

  @tag :no_setup
  test "'start_link' starts new link" do
    conn = Redis.start_link

    assert is_pid(conn) == true
  end

  test "'set' sets new value", %{conn: c} do
    Redis.set(c, "prepara", "que agora")
    Redis.set(c, "prepara", "é hora")

    assert Redix.command(c, ["SMEMBERS", :prepara]) == {:ok, ["é hora", "que agora"]}
  end

  test "'get_members' returns all set members", %{conn: c} do
    Redis.set(c, "prepara", "que agora")
    Redis.set(c, "prepara", "é hora")
    members = Redis.get_members(c, "prepara")

    assert Redix.command(c, ["SMEMBERS", :prepara]) == {:ok, members}
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
