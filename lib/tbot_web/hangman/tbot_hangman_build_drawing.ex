defmodule Tbot.HangmanBuildDrawing do
  @moduledoc """
  Module responsible for altering the guesses drawings according if
  it is a correct or incorrect guess
  """

  alias Tbot.HangmanDrawings, as: Drawings
  alias Tbot.Redis, as: Redis

  def get_drawing_first_interaction(sender_id) do
    # First interaction with new chosen word
    # Steps: chosen_word = "Anitta"
    # 1) Split chosen word into a list -> ["A", "n", "i", "t", "t", "a"]
    # 2) Replace each item in the previous list with a " _ " at the chosen word -> _ _ _ _ _ _
    # 3) Merge the drawing from the guess count with the underscores ->
    # ________
    # |      |
    # |
    # |
    # |
    # |
    #   _ _ _ _ _ _
    chosen_word = chosen_word(sender_id)

    chosen_word
    |> String.split("", trim: true)
    |> map_reduce_string(chosen_word, " _")
    |> merge_underscores_and_drawing(0)
  end

  def get_drawing(sender_id) do
    # Correct guess steps
    # Steps: chosen_word = "Anitta", correct_guesses = "An"
    # 1) Substract all correct guesses from the chosen word -> "itta"
    # 2) Split this into a list -> ["i", "t", "t", "a"]
    # 3) Replace each item in the previous list with a " _ " at the chosen word -> An _ _ _ _
    # 4) Merge the drawing from the guess count with the underscores ->
    # ________
    # |      |
    # |
    # |
    # |
    # |
    #  An _ _ _ _
    chosen_word = chosen_word(sender_id)
    guess_count = incorrect_guess_count(sender_id)

    sender_id
    |> chosen_word_and_guesses_subtraction(chosen_word)
    |> String.split("", trim: true)
    |> map_reduce_string(chosen_word, " _")
    |> merge_underscores_and_drawing(guess_count)
  end

  defp map_reduce_string(guesses, chosen_word, replace) do
    # Explanation: For every iterable in a list, replace each with something and return
    # a string with all the changes.
    # Example: for every letter in ["d", "g"], replace it with "*" in the word "dog".
    # Result: *o*
    Enum.reduce(guesses, chosen_word, fn(num, acc) ->
      String.replace(acc, num, replace)
    end)
  end

  defp merge_underscores_and_drawing(underscores, guess_count) do
    drawing = Drawings.draw(guess_count)
    drawing <> " #{underscores}\n"
  end

  defp chosen_word_and_guesses_subtraction(sender_id, chosen_word) do
    # Exaplanation: for a string of random or not-random substrings of a string, remove them form the string
    # Example: remove "tin" from "Anitta"
    # Result: "Aa"
    correct_guesses = correct_guesses(sender_id)
    map_reduce_string(String.split(correct_guesses, "", trim: true), chosen_word, "")
  end

  defp incorrect_guess_count(sender_id) do
    incorrect_guesses = Redis.get_key_value(sender_id, :incorrect_guesses)

    case incorrect_guesses do
      nil -> 0
      _ -> String.length(incorrect_guesses)
    end
  end

  defp correct_guesses(sender_id) do
    correct_guesses = Redis.get_key_value(sender_id, :correct_guesses)

    case correct_guesses do
      nil -> ""
      _ -> correct_guesses
    end
  end

  defp chosen_word(sender_id) do
    Redis.get_key_value(sender_id, :chosen_word)
  end
end
