defmodule Tbot.SyncUserHangman do
  alias Tbot.HangmanWord, as: HangmanWord
  alias Tbot.Redis, as: Redis

  def sync(magic_map) do
    conn = Redis.start_link
    word = HangmanWord.fetch_random_english_word |> HangmanWord.translate_to_portuguese
    Redis.set(conn, magic_map.sender_id, word)
  end
end
