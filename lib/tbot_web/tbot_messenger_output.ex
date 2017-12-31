defmodule Tbot.MessengerOutput do
  @moduledoc """
  Module responsible for sending POST requests to Messenger's Send API.

  Usage example (with MessengerHelper):
    import Tbot.MessengerOutput
    import Tbot.MessengerHelper

    ...(get messenger entry key value)
    parsed_entry = parse_messenger_entry(entry)
    body = build_request_body(parsed_entry)
    send(body)
  """

  @messenger_url "https://graph.facebook.com/v2.6/me/messages?access_token="
  @headers ["Content-Type": "application/json"]

  def send(body) do
    url = @messenger_url <> messenger_page_token
    HTTPotion.post(url, body: Poison.encode!(body), headers: @headers)
  end

  # TODO: Add other pattern matching methods for quick replies and postbacks
  def build_request_body(%{message: text_msg, sender_id: recipient_id, type: "text"}) do
    msg = %{message: %{text: text_msg}}
    recipient_id |> build_request_recipient |> Map.merge(msg)
  end
  def build_request_body(_), do: raise ArgumentError, message: "Invalid body message map"

  defp build_request_recipient(recipient_id), do: %{recipient: %{id: recipient_id}}
  defp messenger_page_token, do: Application.get_env(:tbot, :messenger_page_token)

end