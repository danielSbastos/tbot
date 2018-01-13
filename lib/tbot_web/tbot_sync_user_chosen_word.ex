defmodule Tbot.SyncUserChosenWord do
  @moduledoc """
  Module responsbile for fetching a random word, translating it to portuguese
  and saving in Redis with the set name as the sender_id and the word as one
  of the values
  """
  alias Tbot.HangmanWord, as: HangmanWord
  alias Tbot.Redis, as: Redis
  alias Tbot.Agent, as: Agent

  def sync(magic_map) do
    conn = Redis.start_link
    word = HangmanWord.fetch_random_english_word |> HangmanWord.translate_to_portuguese

    Agent.start_link
    Agent.update(magic_map.sender_id, :first_interaction)

    Redis.set(conn, magic_map.sender_id, :chosen_word, word)
  end
end
