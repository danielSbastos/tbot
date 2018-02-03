defmodule Tbot.HangmanSyncGuessesTest do
  use TbotWeb.ConnCase

  alias Tbot.HangmanSyncGuesses, as: SyncGuesses
  alias Tbot.Redis, as: Redis

  setup do
    Redis.command(["FLUSHDB"])
    :ok
  end

  test "'update_guesses' updates correct single and first guess" do
    sender_id = "12345"

    Redis.set(sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_guesses("u", :correct_guesses, sender_id)

    assert Redis.get_key_value(sender_id, :correct_guesses) == "u"
  end

  test "'update_guesses' updates more correct guesses" do
    sender_id = "123456"
    Redis.set(sender_id, :chosen_word, "Bunda")
    Redis.set(sender_id, :correct_guesses, "nd")

    SyncGuesses.update_guesses("u", :correct_guesses, sender_id)

    assert Redis.get_key_value(sender_id, :correct_guesses) == "und"
  end

  test "'update_guesses' updates single and incorrect first guess" do
    sender_id = "1234567";
    Redis.set(sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_guesses("q", :incorrect_guesses, sender_id)

    assert Redis.get_key_value(sender_id, :incorrect_guesses) == "q"
  end

  test "'update_guesses' updates more incorrect guesses" do
    sender_id = "12345678"
    Redis.set(sender_id, :chosen_word, "Bunda")
    Redis.set(sender_id, :incorrect_guesses, "ls")

    SyncGuesses.update_guesses("w", :incorrect_guesses, sender_id)

    assert Redis.get_key_value(sender_id, :incorrect_guesses) == "wls"
  end

  test "'reset_all_guesses' reset all guesses" do
    sender_id = "12345678"
    Redis.set(sender_id, :chosen_word, "Bunda")
    Redis.set(sender_id, :incorrect_guesses, "ls")

    SyncGuesses.reset_all_guesses(sender_id)

    assert Redis.get_key_value(sender_id, :incorrect_guesses) == ""
    assert Redis.get_key_value(sender_id, :correct_guesses) == ""
  end
end
