defmodule Tbot.HangmanSyncGuesses do
  @moduledoc """
  Module responsible for updating the correct and incorrect guesses key from the user
  in their Redis hash. It appends to the preexisting guesses the correct or incorrect
  guess and if there is no guess, it simply adds
  """

  alias Tbot.Redis, as: Redis

  def update_correct_guess(guess_word, sender_id) do
    conn = Redis.start_link

    existent_correct_guesses = Redis.get_key_value(conn, sender_id, :correct_guesses)
    if existent_correct_guesses == nil do
      Redis.set(conn, sender_id, :correct_guesses, guess_word)
    else
      Redis.set(conn, sender_id, :correct_guesses, guess_word <> existent_correct_guesses)
    end
  end

  def update_incorrect_guess(guess_word, sender_id) do
    conn = Redis.start_link

    existent_incorrect_guesses = Redis.get_key_value(conn, sender_id, :incorrect_guesses)
    if existent_incorrect_guesses == nil do
      Redis.set(conn, sender_id, :incorrect_guesses, guess_word)
    else
      Redis.set(conn, sender_id, :incorrect_guesses, guess_word <> existent_incorrect_guesses)
    end
  end

  def reset_all_guesses(sender_id) do
    conn = Redis.start_link
    Redis.set(conn, sender_id, :correct_guesses, "")
    Redis.set(conn, sender_id, :incorrect_guesses, "")
  end
end
