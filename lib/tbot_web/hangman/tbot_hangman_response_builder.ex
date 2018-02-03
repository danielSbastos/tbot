defmodule Tbot.HangmanResponseBuilder do
  @moduledoc """
  Module responsible for building the response struct with the correct drawing and sender_id
  """

  alias Tbot.Redis
  alias Tbot.Agent
  alias Tbot.HangmanSyncGuesses, as: SyncGuesses
  alias Tbot.HangmanBuildDrawing, as: BuildDrawing

  def response_data(%{sender_id: sender_id, message: text, type: type}) do
    %Tbot.HangmanResponseData{sender_id: sender_id, message: message(text, sender_id), type: type}
  end

  defp message(text, sender_id) do
    if Agent.alive? do
      Agent.stop
      first_interaction_message(sender_id)
    else
      guess_message(text, sender_id)
    end
  end

  defp first_interaction_message(sender_id) do
    SyncGuesses.reset_all_guesses(sender_id)
    BuildDrawing.get_drawing_first_interaction(sender_id)
  end

  defp guess_message(text, sender_id) do
    if String.length(text) == 1 do
      SyncGuesses.update_guesses(text, guess_flag(text, sender_id), sender_id)
      case incorrect_guess_count(sender_id) do
        6 -> end_of_game_actions_and_message(sender_id)
        _ -> BuildDrawing.get_drawing(sender_id)
      end
    else
      "Desculpe, não entendi."
    end
  end

  defp end_of_game_actions_and_message(sender_id) do
    SyncGuesses.reset_all_guesses(sender_id)
    SyncGuesses.reset_chosen_word(sender_id)
    "Fim de jogo. Você perdeu. Por favor, recomece outra sessão mandando um 'oi'."
  end

  defp incorrect_guess_count(sender_id) do
    incorrect_guesses = Redis.get_key_value(sender_id, :incorrect_guesses)

    case incorrect_guesses do
      nil -> 0
      _ -> String.length(incorrect_guesses)
    end
  end

  defp guess_flag(text, sender_id) do
    case is_guess_in_chosen_word?(text, sender_id) do
      true -> :correct_guesses
      false -> :incorrect_guesses
    end
  end

  defp is_guess_in_chosen_word?(text, sender_id) do
    Redis.get_key_value(sender_id, :chosen_word) =~ text
  end
end
