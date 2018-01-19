defmodule TbotWeb.TbotController do
  use TbotWeb, :controller

  alias Tbot.MessengerInput
  alias Tbot.HangmanResponseBuilder
  alias Tbot.MessengerOutputTask

  def challenge(conn,
    %{"hub.mode" => "subscribe", "hub.verify_token" => token, "hub.challenge" => challenge}) do
    if token == verify_token() do
      conn |> send_resp(200, challenge)
    else
      conn |> put_status(500)
    end
  end
  def challenge(conn, _), do: conn |> put_status(500)

  def webhook(conn, %{"entry" => entry, "object" => "page"}) do
    parsed_entry = MessengerInput.parse_messenger_entry(entry)
    body = HangmanResponseBuilder.response_data(parsed_entry)
    MessengerOutputTask.respond_messenger(body)

    conn |> send_resp(200, "ok")
  end
  def webhook(conn, _),  do: conn |> put_status(500)

  defp verify_token(), do: Application.get_env(:tbot, :messenger_verify_token)
end
