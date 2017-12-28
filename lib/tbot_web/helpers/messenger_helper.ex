defmodule Tbot.MessengerHelper do
  @moduledoc """
  Helper that parses incoming the "entry" key from messenger JSON POST body request
  and returns the user sender_id and the sent text when 'parse_messenger_entry'
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
    text  = parse_message_key(entry)
    sender_id  = parse_sender_key(entry)
    %{"text": text, "sender_id": sender_id}
  end

  # TODO: Take into consideration that a user may not send a text
  defp parse_message_key(msg) do
    message = parse_messaging_key(msg)
    message |> hd |> Map.get("message") |> Map.get("text")
  end

  defp parse_sender_key(msg) do
    sender = parse_messaging_key(msg)
    sender |> hd |> Map.get("sender") |> Map.get("id")
  end

  defp parse_messaging_key(msgn), do: msgn |> hd |>  Map.get("messaging")
end
