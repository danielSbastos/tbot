defmodule Tbot.HangmanBuildDrawing do
  @moduledoc """
  Module responsible for altering the guesses drawings according if
  it is a correct or incorrect guess
  """

  alias Tbot.HangmanDrawings, as: Drawings
  alias Tbot.Redis, as: Redis

  def get_drawing(guess, guess_flag = :incorrect_guesses, sender_id) do
    guess_count = incorrect_guess_count(sender_id)

    sender_id
    |> chosen_word
    |> build_word_underscores
    |> merge_underscores_and_drawing(guess_count, guess_flag)
  end

  #################### INCORRECT GUESS METHODS ####################################
  defp build_word_underscores(chosen_word) do
    String.duplicate("_ ", String.length(chosen_word) - 1) <> "_"
  end

  defp merge_underscores_and_drawing(underscores, guess_count, _guess_flag = :incorrect_guesses) do
    [drawing | sentence] = Drawings.draw(guess_count)
    drawing <> " #{underscores}" <> "\n\n" <> hd sentence
  end
  #################################################################################


  #################### CORRECT GUESS METHODS ####################################
  def get_drawing(guess, guess_flag = :correct_guesses, sender_id) do
    # Correct guess steps
    # Steps: chosen_word = "Anitta", correct_guesses = "An"
    # 1) Substract all correct guesses from the chosen word -> "itta"
    # 2) Split this into a list -> ["i", "t", "t", "a"]
    # 3) Replace each item in the previous list with a " _ " at the chosen word -> An _ _ _ _
    # 4) Merge the drawing from the guess count with the underscores and sentence ->
    # ________
    # |      |
    # |
    # |
    # |
    # |
    #  An _ _ _ _

    # Boa! Fale mais uma letra!"
    chosen_word = chosen_word(sender_id)

    sender_id
    |> chosen_word_and_guesses_subtraction(chosen_word)
    |> String.split("", trim: true)
    |> map_reduce_string(chosen_word, " _")
    |> merge_underscores_and_drawing(incorrect_guess_count(sender_id), guess_flag)
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

  defp merge_underscores_and_drawing(underscores, guess_count, _guess_flag = :correct_guesses) do
    [drawing | _] = Drawings.draw(guess_count)
    drawing <> " #{underscores}" <> "\n\n" <> "Boa! Fale mais uma letra!"
  end

 defp chosen_word_and_guesses_subtraction(sender_id, chosen_word) do
  # Exaplanation: for a string of random or not-random substrings of a string, remove them form the string
  # Example: remove "tin" from "Anitta"
  # Result: "Aa"
  guesses =
  Redis.start_link
  |> Redis.get_key_value(sender_id, :correct_guesses)

  map_reduce_string(String.split(guesses, "", trim: true), chosen_word, "")
 end
 #################################################################################

 defp incorrect_guess_count(sender_id) do
   incorrect_guesses =
   Redis.start_link
   |> Redis.get_key_value(sender_id, :incorrect_guesses)

   case incorrect_guesses do
     nil -> 0
     _ -> String.length(incorrect_guesses)
   end
end

 defp chosen_word(sender_id) do
   Redis.start_link
   |> Redis.get_key_value(sender_id, :chosen_word)
 end
end
