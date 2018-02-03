defmodule Tbot.RedisTest do
  use TbotWeb.ConnCase

  alias Tbot.Redis, as: Redis

  setup do
    Redis.command(["FLUSHDB"])
    :ok
  end

  test "'set' adds new key and value to hash" do
    Redis.set("12345", "prepara", "que agora")
    Redis.set("12345", "é hora do show", "das poderosas")

    assert Redis.command(["HGETALL", "12345"]) ==
      {:ok, ["prepara", "que agora", "é hora do show", "das poderosas"]}
  end

  test "'get_members' returns all hash members" do
    Redis.set("12345", "prepara", "que agora")
    Redis.set("12345", "é hora do show", "das poderosas")
    members = Redis.get_members("12345")

    assert Redis.command(["HGETALL", "12345"]) == {:ok, members}
  end

  test "'get_key_value' returns all hash's key value" do
    Redis.set("12345", "prepara", "que agora")
    Redis.set("12345", "é hora do show", "das poderosas")
    value = Redis.get_key_value("12345", "prepara")

    assert Redis.command(["HGET", "12345", "prepara"]) == {:ok, value}
  end
end
