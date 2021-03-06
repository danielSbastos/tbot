defmodule TbotWeb.TbotMessengerInputTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerInput, as: MessengerInput

  import Mock

  test "messenger entry value returns sender_id and text" do
    sender_id = "12345"
    text = "vai malandra"
    parsed_entry = stub_messenger_entry_value(sender_id, text) |> MessengerInput.parse_messenger_entry

    assert parsed_entry == %Tbot.MessengerRequestData{message: "vai malandra", sender_id: "12345", type: "text"}
  end

  test "messenger entry value with magic word" do
    with_mock HTTPotion, [
        get: fn(_url) -> stub_random_word_response() end,
        post: fn(_url, _body_and_headers) -> stub_translation() end
    ] do

      sender_id = "12345"
      text = "oi"
      parsed_entry = stub_messenger_entry_value(sender_id, text) |> MessengerInput.parse_messenger_entry

      assert parsed_entry == %Tbot.MessengerRequestData{message: "oi", sender_id: "12345", type: "text"}
    end
  end

  defp stub_messenger_entry_value(sender_id, text) do
    [%{
      "id" => "1231930516917414",
      "time" => "1500408432080",
      "messaging" => [%{
        "sender" => %{"id" => sender_id},
        "recipient" => %{"id" => "1231930516917414"},
        "timestamp" => "1500408431958",
        "message" => %{
          "mid" => "mid.$cAAQ6nOh9tL9jiJUNVldV0_Eirk_R",
          "seq" => "30259",
          "text" => text,
        }
      }]
    }]
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
