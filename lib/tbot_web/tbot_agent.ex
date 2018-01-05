defmodule Tbot.Agent do
  @moduledoc false
  use Agent

  def start_link do
    Agent.start_link(&Map.new/0, name: __MODULE__)
  end

  def update(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
