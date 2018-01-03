defmodule Tbot.HangmanWordTest do
  use TbotWeb.ConnCase

  alias Tbot.HangmanWord, as: HangmanWord

  import Mock

  test "'fetch_random_english_word' returns word" do
    with_mock HTTPotion, [get: fn(_url) -> stub_random_word_response end] do
      response = HangmanWord.fetch_random_english_word

      assert called HTTPotion.get(
        "http://api.wordnik.com:80/v4/words.json/randomWord?api_key=" <> wordnik_api_key
      )
      assert response == "unstepped"
    end
  end

  test "'translate_to_portuguese' returns translated word" do
    with_mock HTTPotion, [post: fn(_url, _body_and_headers) -> stub_translation end] do
      word = "Adriatic Sea"

      response = HangmanWord.translate_to_portuguese(word)

      assert called HTTPotion.post(
        "https://translate.yandex.net/api/v1.5/tr.json/translate?lang=en-pt&key=" <> yandex_api_key,
        body: "text=" <> word,
        headers: ["Content-Type": "application/x-www-form-urlencoded"]
      )
      assert response == "Mar Adriático"
    end
  end

  defp stub_random_word_response do
    %HTTPotion.Response{
      body: "{\"id\":349663,\"word\":\"unstepped\"}",
      headers: %HTTPotion.Headers{
        hdrs: %{
          "access-control-allow-headers" => "Origin, X-Atmosphere-tracking-id, X-Atmosphere-Framework, X-Cache-Date, Content-Type, X-Atmosphere-Transport, X-Remote, api_key, auth_token, *",
          "access-control-allow-methods" => "POST, GET, OPTIONS, PUT, DELETE",
          "access-control-allow-origin" => "*",
          "access-control-request-headers" => "Origin, X-Atmosphere-tracking-id, X-Atmosphere-Framework, X-Cache-Date, Content-Type, X-Atmosphere-Transport,  X-Remote, api_key, *",
          "connection" => "close",
          "content-type" => "application/json; charset=utf-8",
          "date" => "Wed, 03 Jan 2018 19:29:45 GMT",
          "wordnik-api-version" => "4.12.20"
        }
      },
     status_code: 200
    }
  end

  defp stub_translation do
    %HTTPotion.Response{
      body: "{\"code\":200,\"lang\":\"en-pt\",\"text\":[\"Mar Adriático\"]}",
      headers: %HTTPotion.Headers{
        hdrs: %{
          "cache-control" => "no-store",
          "connection" => "keep-alive", "content-length" => "53",
          "content-type" => "application/json; charset=utf-8",
          "date" => "Wed, 03 Jan 2018 19:40:48 GMT", "keep-alive" => "timeout=120",
          "server" => "nginx/1.6.2", "x-content-type-options" => "nosniff"
        }
      },
     status_code: 200
    }
  end

  defp wordnik_api_key, do: Application.get_env(:tbot, :wordnik_api_key)
  defp yandex_api_key, do: Application.get_env(:tbot, :yandex_api_key)
end
