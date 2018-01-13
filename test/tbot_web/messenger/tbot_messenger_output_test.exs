defmodule TbotWeb.TbotMessengerOutputTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerOutput
  alias Tbot.HangmanResponseData

  import Mock

  test "'build_request_body' returns correct text message structure" do
    text = "beam me up, scotty"; sender_id = "12345"
    message_map = %HangmanResponseData{message: text, sender_id: sender_id, type: "text"}
    request_body = MessengerOutput.build_request_body(message_map)

    assert request_body == %Tbot.MessengerResponseData{
      message: %{text: text}, recipient: %{id: sender_id}
    }
  end

  test "'build_request_body' raises error if wrong map is passed" do
    message_map = %{bla: "ok", type: "text"}

    assert_raise ArgumentError, ~r/^Invalid body message map/, fn ->
      MessengerOutput.build_request_body(message_map)
    end
  end

  test "'send' sends POST request to messenger with correct params" do
    with_mock HTTPotion, [post: fn(_url, _headers_and_body) -> "ok" end] do

      text = "beam me up, scotty"; sender_id = "12345"
      message_map = %HangmanResponseData{message: text, sender_id: sender_id, type: "text"}
      request_body = MessengerOutput.build_request_body(message_map)
      MessengerOutput.send(request_body)

      assert called HTTPotion.post(
        "https://graph.facebook.com/v2.6/me/messages?access_token=" <> messenger_page_token(),
        body: Poison.encode!(request_body), headers: ["Content-Type": "application/json"]
      )
    end
  end

  defp messenger_page_token(), do: Application.get_env(:tbot, :messenger_page_token)
end
