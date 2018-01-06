defmodule Tbot.MessengerInput do
  alias Tbot.MessengerRequestData, as: MessengerRequestData
  alias Tbot.SyncUserChosenWord, as: SyncUserChosenWord

  @moduledoc """
  Input module that parses the incoming "entry" key from messenger JSON POST body request
  and returns the user sender_id, the message and its type text when 'parse_messenger_entry'
  is called.
  - Below: a sample POST request from messenger. The method 'parse_messenger_entry'
    receives the key "entry" and its values only.
    %{
      "object" => "page",
      "entry" => [%{
        "id" => "1231930516917414",
        "time" => "1500408432080",
        "messaging" => [%{
          "sender" => %{"id" => "sender_id"},
          "recipient" => %{"id" => "1231930516917414"},
          "timestamp" => "1500408431958",
          "message" => %{
            "mid" => "mid.$cAAQ6nOh9tL9jiJUNVldV0_Eirk_R",
            "seq" => "30259",
            "text" => "text",
          }
        }]
      }]
   }
  """

  def parse_messenger_entry(entry) do
    message = parse_message_key(entry)
    sender = parse_sender_key(entry)
    map = Map.merge(message, sender, fn _k, v1, v2 ->  v2 || v1 end)
    if is_magic_word?(map.message) do
      SyncUserChosenWord.sync(map)
    end
    map
  end

  defp parse_message_key(msg) do
    message = msg
    |> parse_messaging_key
    |> hd
    |> Map.get("message")
    define_message_type(message)
  end

  defp define_message_type(%{"mid" => _, "seq" => _, "text" => text}) do
    %MessengerRequestData{message: text, type: "text"}
  end

  defp parse_sender_key(msg) do
    sender_id = msg
    |> parse_messaging_key
    |> hd
    |> Map.get("sender")
    |> Map.get("id")
    %MessengerRequestData{sender_id: sender_id}
  end

  # NOTE: This will be altered to a "get started" and "persistent menu"
  # and, therefore, the message type will alter to "postback"
  defp is_magic_word?(text) do
    text == "oi"
  end

  defp parse_messaging_key(msgn), do: msgn |> hd |>  Map.get("messaging")
end
