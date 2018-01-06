defmodule Tbot.HangmanSyncGuessesTest do
  use TbotWeb.ConnCase

  alias Tbot.HangmanSyncGuesses, as: SyncGuesses
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

  test "'update_correct_guess' updates single and first guess", %{conn: conn} do
    sender_id = "12345"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_correct_guess("u", sender_id)

    assert Redis.get_key_value(conn, sender_id, :correct_guesses) == "u"
  end

  test "'update_correct_guess' updates more guesses", %{conn: conn} do
    sender_id = "123456"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")
    Redis.set(conn, sender_id, :correct_guesses, "nd")

    SyncGuesses.update_correct_guess("u", sender_id)

    assert Redis.get_key_value(conn, sender_id, :correct_guesses) == "und"
  end

  test "'update_incorrect_guess' single and first guess", %{conn: conn} do
    sender_id = "1234567"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_incorrect_guess("q", sender_id)

    assert Redis.get_key_value(conn, sender_id, :incorrect_guesses) == "q"
  end

  test "'update_incorrect_guess' updates more guesses", %{conn: conn} do
    sender_id = "12345678"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")
    Redis.set(conn, sender_id, :incorrect_guesses, "ls")

    SyncGuesses.update_incorrect_guess("w", sender_id)

    assert Redis.get_key_value(conn, sender_id, :incorrect_guesses) == "wls"
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
