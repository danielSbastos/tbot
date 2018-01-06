defmodule Tbot.MessengerResponseBuilder do
  @moduledoc """
  Module responsible for altering the struct %Tbot.MessengerRequestData
  by replacing the message value with the interpreted one by the bot.
  """

  alias Tbot.Redis, as: Redis
  alias Tbot.Agent, as: Agent
  alias Tbot.HangmanSyncGuesses, as: SyncGuesses
  alias Tbot.HangmanDrawings, as: Drawings

  def response_data(
    %Tbot.MessengerRequestData{sender_id: sender_id, message: text, type: type}) do

    %Tbot.MessengerRequestData{sender_id: sender_id, message: define_interaction(text, sender_id), type: type}
  end

  defp define_interaction(text, sender_id) do
    text = if Agent.alive? do
      chosen_word = Agent.get(sender_id)
      Agent.stop
      first_interaction_message(chosen_word, sender_id)
    else
      check_for_guess(text, sender_id)
    end
  end

  ############# FIRST INTERACTION METHODS #########################

  defp first_interaction_message(chosen_word, sender_id) do
    SyncGuesses.reset_all_guesses(sender_id)
    chosen_word
    |> build_word_underscores
    |> merge_underscores_and_drawing
  end

  defp build_word_underscores(chosen_word) do
    String.duplicate("_ ", String.length(chosen_word) - 1) <> "_"
  end

  defp merge_underscores_and_drawing(underscores) do
    [drawing | sentence] = Drawings.draw(0)
    drawing <> " #{underscores}" <> "\n\n" <> hd sentence
  end

  ###############################################################

  defp check_for_guess(text, sender_id) do
    if String.length(text) == 1 do
      if is_guess_in_chosen_word?(text, sender_id) do
        SyncGuesses.update_correct_guess(text, sender_id)
        "correct"
      else
        SyncGuesses.update_incorrect_guess(text, sender_id)
        "incorrect"
      end
    else
      "Desculpe, não entendi"
    end
  end

  defp is_guess_in_chosen_word?(text, sender_id) do
    chosen_word = Redis.start_link |> Redis.get_key_value(sender_id, :chosen_word)
    chosen_word =~ text
  end
end
