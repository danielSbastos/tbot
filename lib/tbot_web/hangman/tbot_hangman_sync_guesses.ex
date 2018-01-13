defmodule Tbot.HangmanSyncGuesses do
  @moduledoc """
  Module responsible for updating the correct and incorrect guesses key from the user
  in their Redis hash. It appends to the preexisting guesses the correct or incorrect
  guess and if there is no guess, it simply adds
  """

  alias Tbot.Redis

  def update_guesses(guess, guess_flag, sender_id) do
    conn = Redis.start_link

    existent_guesses = Redis.get_key_value(conn, sender_id, guess_flag)
    if existent_guesses == nil do
      Redis.set(conn, sender_id, guess_flag, guess)
    else
      Redis.set(conn, sender_id, guess_flag, guess <> existent_guesses)
    end
  end

  def reset_all_guesses(sender_id) do
    conn = Redis.start_link
    Redis.set(conn, sender_id, :correct_guesses, "")
    Redis.set(conn, sender_id, :incorrect_guesses, "")
  end
end
