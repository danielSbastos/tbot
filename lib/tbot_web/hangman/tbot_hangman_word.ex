defmodule Tbot.HangmanWord do
  @moduledoc """
  Module that is responsible for fetching a random english word with Wordnik's api
  and translating it to portuguese with Yandex.
  """
  def fetch_random_english_word do
    "http://api.wordnik.com:80/v4/words.json/randomWord?api_key=" <> wordnik_api_key()
    |> HTTPotion.get
    |> parse_random_word_response
  end

  def translate_to_portuguese(english_word) do
    headers = ["Content-Type": "application/x-www-form-urlencoded"]
    body = "text=" <> english_word
    "https://translate.yandex.net/api/v1.5/tr.json/translate?lang=en-pt&key=" <> yandex_api_key()
    |> HTTPotion.post(body: body, headers: headers)
    |> parse_translation_response
  end

  defp parse_random_word_response(response) do
    response
    |> Map.get(:body)
    |> Poison.decode!
    |> Map.get("word")
  end

  defp parse_translation_response(response) do
    response
    |> Map.get(:body)
    |> Poison.decode!
    |> Map.get("text")
    |> hd
  end

  defp wordnik_api_key(), do: Application.get_env(:tbot, :wordnik_api_key)
  defp yandex_api_key(), do: Application.get_env(:tbot, :yandex_api_key)
end
