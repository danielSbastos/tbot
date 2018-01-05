defmodule Tbot.SyncUserHangman do
  @moduledoc """
  Module responsbile for fetching a random word, translating it to portuguese
  and saving in Redis with the set name as the sender_id and the word as one
  of the values
  """
  alias Tbot.HangmanWord, as: HangmanWord
  alias Tbot.Redis, as: Redis

  def sync(magic_map) do
    conn = Redis.start_link
    word = HangmanWord.fetch_random_english_word |> HangmanWord.translate_to_portuguese
    Redis.set(conn, magic_map.sender_id, :chosen_word, word)
  end
end
