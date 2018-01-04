defmodule Tbot.MessengerOutput do
  alias Tbot.MessengerResponseData, as: MessengerResponseData

  @moduledoc """
  Module responsible for sending POST requests to Messenger's Send API.

  Usage example (with MessengerInput):
    alias Tbot.MessengerInput, as: MessengerInput
    alias Tbot.MessengerOutput, as: MessengerOutput

    ...(get messenger entry key value)
    parsed_entry = MessengerInput.parse_messenger_entry(entry)
    body = MessengerOutput.build_request_body(parsed_entry)
    MessengerOutput.send(body)
  """

  @messenger_url "https://graph.facebook.com/v2.6/me/messages?access_token="
  @headers ["Content-Type": "application/json"]

  def send(body) do
    url = @messenger_url <> messenger_page_token()
    HTTPotion.post(url, body: Poison.encode!(body), headers: @headers)
  end

  # TODO: Add other pattern matching methods for quick replies and postbacks
  def build_request_body(%Tbot.MessengerRequestData{
      message: text_msg, sender_id: recipient_id, type: "text"}) do

    message = %MessengerResponseData{message: %{text: text_msg}}
    recipient_id
    |> build_request_recipient
    |> Map.merge(message, fn _k, v1, v2 ->  v2 || v1 end)
  end
  def build_request_body(_), do: raise ArgumentError, message: "Invalid body message map"

  defp build_request_recipient(recipient_id) do
    %MessengerResponseData{recipient: %{id: recipient_id}}
  end

  defp messenger_page_token(), do: Application.get_env(:tbot, :messenger_page_token)
end
