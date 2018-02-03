defmodule Tbot.HangmanSyncGuesses do
  @moduledoc """
  Module responsible for updating the correct and incorrect guesses key from the user
  in their Redis hash. It appends to the preexisting guesses the correct or incorrect
  guess and if there is no guess, it simply adds
  """

  alias Tbot.Redis
  alias Tbot.HangmanWord, as: NewChosenWord

  def update_guesses(guess, guess_flag, sender_id) do
    existent_guesses = Redis.get_key_value(sender_id, guess_flag)
    if existent_guesses == nil do
      Redis.set(sender_id, guess_flag, guess)
    else
      Redis.set(sender_id, guess_flag, guess <> existent_guesses)
    end
  end

  def reset_chosen_word(sender_id) do
    Redis.set(sender_id, :chosen_word, "")
  end

  def reset_all_guesses(sender_id) do
    Redis.set(sender_id, :correct_guesses, "")
    Redis.set(sender_id, :incorrect_guesses, "")
  end
end
