defmodule Tbot.HangmanResponseBuilderTest do
  use TbotWeb.ConnCase

  alias Tbot.HangmanResponseBuilder, as: ResponseBuilder
  alias Tbot.Redis
  alias Tbot.Agent

  import Mock

  setup do
    Redis.command(["FLUSHDB"])
    :ok
  end

  test "first interaction with magic word" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "oi", type: "text"}
    save_word_in_redis(sender_id, "Anitta")
    put_word_in_agent(sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |
          |
          |
          |
            _ _ _ _ _ _
          """
      }
  end

  test "first guess with correct letter" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "A", type: "text"}
    save_word_in_redis(sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |
          |
          |
          |
           A _ _ _ _ _
          """
      }
  end

  test "fourth correct guess with two incorrect guesses" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "A", type: "text"}

    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :correct_guesses, "ant")
    update_redis(sender_id, :incorrect_guesses, "wo")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |      0
          |     /
          |
          |
           An _tta
          """
      }
  end

  test "fifth incorrect guess with three correct guesses" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "p", type: "text"}

    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :correct_guesses, "ant")
    update_redis(sender_id, :incorrect_guesses, "wozr")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |      0
          |     /|\\
          |     /
          |
            _n _tta
          """
      }
  end

  test "first guess with incorrect letter" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "w", type: "text"}
    save_word_in_redis(sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |      0
          |
          |
          |
            _ _ _ _ _ _
          """
      }
  end

  test "fourth guess with incorrect letter" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "p", type: "text"}
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :incorrect_guesses, "wdb")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message:
          """
          ________
          |      |
          |      0
          |     /|\\
          |
          |
            _ _ _ _ _ _
          """
      }
  end

  test "text with random word" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "a danada sou eu", type: "text"}

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.HangmanResponseData{
        sender_id: sender_id,
        type: "text",
        message: "Desculpe, não entendi."
      }
  end

  test "last possible incorrect guess results in game over and game stopped" do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "m", type: "text"}
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :incorrect_guesses, "woldb")

    with_mock HTTPotion, [
      get: fn(_url) -> stub_random_word_response() end,
      post: fn(_url, _body_and_headers) -> stub_translation() end
    ] do

      parsed_message = ResponseBuilder.response_data(message_map)

      assert parsed_message ==
        %Tbot.HangmanResponseData{
          sender_id: sender_id,
          type: "text",
          message: "Fim de jogo. Você perdeu. Por favor, recomece outra sessão mandando um 'oi'."
        }
    end
  end

  defp save_word_in_redis(sender_id, chosen_word) do
    Redis.set(sender_id, :chosen_word, chosen_word)
  end

  defp update_redis(sender_id, key, value) do
    Redis.set(sender_id, key, value)
  end

  defp put_word_in_agent(sender_id, chosen_word) do
    Agent.start_link
    Agent.update(sender_id, chosen_word)
  end

  defp stub_random_word_response() do
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

  defp stub_translation() do
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
end
