defmodule Tbot.MessengerResponseBuilder do
  @moduledoc """
  Module responsible for altering the struct %Tbot.MessengerRequestData
  by replacing the message value with the interpreted one by the bot.
  """

  alias Tbot.Redis
  alias Tbot.Agent
  alias Tbot.HangmanSyncGuesses, as: SyncGuesses
  alias Tbot.HangmanBuildDrawing, as: BuildDrawing

  def response_data(
    %Tbot.MessengerRequestData{sender_id: sender_id, message: text, type: type}) do

    %Tbot.MessengerRequestData{sender_id: sender_id, message: define_interaction(text, sender_id), type: type}
  end

  defp define_interaction(text, sender_id) do
    if Agent.alive? do
      Agent.stop
      first_interaction_message(sender_id)
    else
      check_for_guess(text, sender_id)
    end
  end

  defp first_interaction_message(sender_id) do
    SyncGuesses.reset_all_guesses(sender_id)
    BuildDrawing.get_drawing_first_interaction(sender_id)
  end

  defp check_for_guess(text, sender_id) do
    if String.length(text) == 1 do
      guess_flag =
        case is_guess_in_chosen_word?(text, sender_id) do
          true -> :correct_guesses
          false -> :incorrect_guesses
        end
      SyncGuesses.update_guesses(text, guess_flag, sender_id)
      BuildDrawing.get_drawing(sender_id)
    else
      "Desculpe, não entendi"
    end
  end

  defp is_guess_in_chosen_word?(text, sender_id) do
    chosen_word = Redis.start_link |> Redis.get_key_value(sender_id, :chosen_word)
    chosen_word =~ text
  end
end
