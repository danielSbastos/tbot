defmodule Tbot.MessengerResponseBuilderTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerResponseBuilder, as: ResponseBuilder
  alias Tbot.Redis, as: Redis

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
    save_word_in_redis(conn, "12345")

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

  defp save_word_in_redis(conn, sender_id) do
    Redis.set(conn, sender_id, :chosen_word, "Anitta")
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
