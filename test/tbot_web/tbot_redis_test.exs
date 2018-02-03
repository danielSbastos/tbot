# defmodule Tbot.RedisTest do
#   use TbotWeb.ConnCase

#   alias Tbot.Redis, as: Redis

#   setup_all do
#     {:ok, conn} = Redix.start_link(redis_host())
#     Redix.command!(conn, ["FLUSHDB"])
#     Redix.stop(conn)
#     :ok
#   end

#   setup context do
#     if context[:no_setup] do
#       {:ok, %{}}
#     else
#       {:ok, conn} = Redix.start_link(redis_host())
#       {:ok, %{conn: conn}}
#     end
#   end

#   test "'set' adds new key and value to hash", %{conn: c} do
#     Redis.set(c, "12345", "prepara", "que agora")
#     Redis.set(c, "12345", "é hora do show", "das poderosas")

#     assert Redix.command(c, ["HGETALL", "12345"]) ==
#       {:ok, ["prepara", "que agora", "é hora do show", "das poderosas"]}
#   end

#   test "'get_members' returns all hash members", %{conn: c} do
#     Redis.set(c, "12345", "prepara", "que agora")
#     Redis.set(c, "12345", "é hora do show", "das poderosas")
#     members = Redis.get_members(c, "12345")

#     assert Redix.command(c, ["HGETALL", "12345"]) == {:ok, members}
#   end

#   test "'get_key_value' returns all hash's key value", %{conn: c} do
#     Redis.set(c, "12345", "prepara", "que agora")
#     Redis.set(c, "12345", "é hora do show", "das poderosas")
#     value = Redis.get_key_value(c, "12345", "prepara")

#     assert Redix.command(c, ["HGET", "12345", "prepara"]) == {:ok, value}
#   end

#   defp redis_host(), do: Application.get_env(:tbot, :redis_host)
# end
