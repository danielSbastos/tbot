defmodule Tbot.MessengerHelper do
  def parse_messenger_entry(entry) do
    text  = parse_message_key(entry)
    sender_id  = parse_sender_key(entry)
    %{"text": text, "sender_id": sender_id}
  end

  defp parse_message_key(msg) do
    parse_messaging_key(msg)
    |> hd |> Map.get("message") |> Map.get("text")
  end

  defp parse_sender_key(msg) do
    parse_messaging_key(msg)
    |> hd |> Map.get("sender") |> Map.get("id")
  end

  defp parse_messaging_key(msgn), do: msgn |> hd |>  Map.get("messaging")
end
