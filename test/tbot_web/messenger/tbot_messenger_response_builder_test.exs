defmodule Tbot.MessengerResponseBuilderTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerResponseBuilder, as: ResponseBuilder
  alias Tbot.Redis, as: Redis
  alias Tbot.Agent, as: Agent

  setup_all do
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

  test "first interaction with random word", %{conn: conn} do
    message_map = %Tbot.MessengerRequestData{sender_id: "12345", message: "oi", type: "text"}
    save_word_in_redis(conn, "12345", "Anitta")
    put_word_in_agent("12345", "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
        sender_id: "12345",
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
          <>
          "\nVamos lá! Fale a primeira letra!"
      }
  end

  test "guess with correct guess letter", %{conn: conn} do
    message_map = %Tbot.MessengerRequestData{sender_id: "12345", message: "A", type: "text"}
    save_word_in_redis(conn, "12345", "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
        sender_id: "12345",
        type: "text",
        message: "correct"
      }
  end

  test "guess with incorrect guess letter", %{conn: conn} do
    message_map = %Tbot.MessengerRequestData{sender_id: "12345", message: "w", type: "text"}
    save_word_in_redis(conn, "12345", "Anitta")

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
        sender_id: "12345",
        type: "text",
        message: "incorrect"
      }
  end

  test "text with random word" do
    message_map = %Tbot.MessengerRequestData{sender_id: "12345", message: "a danada sou eu", type: "text"}

    parsed_message = ResponseBuilder.response_data(message_map)

    assert parsed_message ==
      %Tbot.MessengerRequestData{
        sender_id: "12345",
        type: "text",
        message: "Desculpe, não entendi"
      }
  end

  defp save_word_in_redis(conn, sender_id, chosen_word) do
    Redis.set(conn, sender_id, :chosen_word, chosen_word)
  end

  defp put_word_in_agent(sender_id, chosen_word) do
    Agent.start_link
    Agent.update(sender_id, chosen_word)
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
