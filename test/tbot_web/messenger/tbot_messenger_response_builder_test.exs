defmodule Tbot.MessengerResponseBuilderTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerResponseBuilder, as: ResponseBuilder
  alias Tbot.Redis, as: Redis
  alias Tbot.Agent, as: Agent

  setup do
    {:ok, conn} = Redix.start_link(redis_host())
    Redix.command!(conn, ["FLUSHDB"])
    Redix.stop(conn)
    :ok
  end

  setup context do
    if context[:no_setup] do
      {:ok, %{}}
    else
      {:ok, conn} = Redix.start_link(redis_host())
      {:ok, %{conn: conn}}
    end
  end

  test "first interaction with magic word", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "oi", type: "text"}
    save_word_in_redis(conn, sender_id, "Anitta")
    put_word_in_agent(sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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

  test "first guess with correct letter", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "A", type: "text"}
    save_word_in_redis(conn, sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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

  test "fourth correct guess with two incorrect guesses", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "A", type: "text"}

    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :correct_guesses, "ant")
    update_redis(conn, sender_id, :incorrect_guesses, "wo")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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

  test "fifth incorrect guess with three correct guesses", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "p", type: "text"}

    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :correct_guesses, "ant")
    update_redis(conn, sender_id, :incorrect_guesses, "wozr")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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

  test "first guess with incorrect letter", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "w", type: "text"}
    save_word_in_redis(conn, sender_id, "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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

  test "fourth guess with incorrect letter", %{conn: conn} do
    sender_id = "12345"
    message_map = %Tbot.MessengerRequestData{sender_id: sender_id, message: "p", type: "text"}
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :incorrect_guesses, "wdb")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
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
      %Tbot.MessengerRequestData{
        sender_id: sender_id,
        type: "text",
        message: "Desculpe, não entendi"
      }
  end

  defp save_word_in_redis(conn, sender_id, chosen_word) do
    Redis.set(conn, sender_id, :chosen_word, chosen_word)
  end

  defp update_redis(conn, sender_id, key, value) do
    Redis.set(conn, sender_id, key, value)
  end

  defp put_word_in_agent(sender_id, chosen_word) do
    Agent.start_link
    Agent.update(sender_id, chosen_word)
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
