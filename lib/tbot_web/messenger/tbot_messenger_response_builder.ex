defmodule Tbot.MessengerResponseBuilder do
  @moduledoc """
  Module responsible for altering the struct %Tbot.MessengerRequestData
  by replacing the message value with the interpreted one by the bot.
  """

  alias Tbot.Redis, as: Redis
  alias Tbot.HangmanDrawings, as: HangmanDrawings

  def response_data(
    %Tbot.MessengerRequestData{sender_id: sender_id, message: text, type: type}) do

    # TODO: Implement checking for guesses' tries
    %Tbot.MessengerRequestData{
      sender_id: sender_id, message: first_interaction_message(sender_id), type: type
    }
  end

  defp first_interaction_message(sender_id) do
    sender_id
    |> build_word_underscores
    |> merge_underscores_and_drawing
  end

  defp build_word_underscores(sender_id) do
    word = Redis.start_link |> Redis.get_key_value(sender_id, :chosen_word)
    # In order to avoid nil results. See https://xkcd.com/221/
    word = word || "Abracadabra"
    String.duplicate("_ ", String.length(word) - 1) <> "_"
  end

  defp merge_underscores_and_drawing(underscores) do
    # TODO: Implement checking for guesses' tries
    [drawing | sentence] = HangmanDrawings.draw(0)
    drawing <> " #{underscores}" <> "\n\n" <> hd sentence
  end
end
