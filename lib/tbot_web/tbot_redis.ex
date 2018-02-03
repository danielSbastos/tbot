defmodule Tbot.Redis do
  @moduledoc false
  def set(name, key, value) do
    Redix.command(:"redix_#{random_index()}", ["HSET", name, key, value])
  end

  def get_members(name) do
    {:ok, value} = Redix.command(:"redix_#{random_index()}", ["HGETALL", name])
    value
  end

  def get_key_value(name, key) do
    {:ok, value} = Redix.command(:"redix_#{random_index()}", ["HGET", name, key])
    value
  end

  def command(command) do
    {:ok, value} = Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), redis_pool_size())
  end

  defp redis_pool_size(), do: Application.get_env(:tbot, :redis_pool_size)
  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
