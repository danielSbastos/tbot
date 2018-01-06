defmodule Tbot.SyncUserChosenWordTest do
  use TbotWeb.ConnCase

  alias Tbot.SyncUserChosenWord, as: SyncUserChosenWord

  import Mock

  setup_all do
    {:ok, conn} = Redix.start_link(redis_host())
    Redix.command!(conn, ["FLUSHDB"])
    Redix.stop(conn)
    :ok
  end

  test "'sync' fetches word and saves in redis" do
    with_mock HTTPotion, [
      get: fn(_url) -> stub_random_word_response() end,
      post: fn(_url, _body_and_headers) -> stub_translation() end
    ] do

      sync = SyncUserChosenWord.sync(%{sender_id: "12345"})

      assert sync == {:ok, 1}

      {:ok, conn} = Redix.start_link(redis_host())
      assert Redix.command(conn, ["HGETALL", "12345"]) == {:ok, ["chosen_word", "Mar Adriático"]}
    end
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
