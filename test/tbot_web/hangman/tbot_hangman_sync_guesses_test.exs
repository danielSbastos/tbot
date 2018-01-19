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

  test "'update_guesses' updates correct single and first guess", %{conn: conn} do
    sender_id = "12345"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_guesses("u", :correct_guesses, sender_id)

    assert Redis.get_key_value(conn, sender_id, :correct_guesses) == "u"
  end

  test "'update_guesses' updates more correct guesses", %{conn: conn} do
    sender_id = "123456"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")
    Redis.set(conn, sender_id, :correct_guesses, "nd")

    SyncGuesses.update_guesses("u", :correct_guesses, sender_id)

    assert Redis.get_key_value(conn, sender_id, :correct_guesses) == "und"
  end

  test "'update_guesses' updates single and incorrect first guess", %{conn: conn} do
    sender_id = "1234567";
    Redis.set(conn, sender_id, :chosen_word, "Bunda")

    SyncGuesses.update_guesses("q", :incorrect_guesses, sender_id)

    assert Redis.get_key_value(conn, sender_id, :incorrect_guesses) == "q"
  end

  test "'update_guesses' updates more incorrect guesses", %{conn: conn} do
    sender_id = "12345678"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")
    Redis.set(conn, sender_id, :incorrect_guesses, "ls")

    SyncGuesses.update_guesses("w", :incorrect_guesses, sender_id)

    assert Redis.get_key_value(conn, sender_id, :incorrect_guesses) == "wls"
  end

  test "'reset_all_guesses' reset all guesses", %{conn: conn} do
    sender_id = "12345678"
    Redis.set(conn, sender_id, :chosen_word, "Bunda")
    Redis.set(conn, sender_id, :incorrect_guesses, "ls")

    SyncGuesses.reset_all_guesses(sender_id)

    assert Redis.get_key_value(conn, sender_id, :incorrect_guesses) == ""
    assert Redis.get_key_value(conn, sender_id, :correct_guesses) == ""
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

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
