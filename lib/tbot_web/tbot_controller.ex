defmodule TbotWeb.TbotController do
  use TbotWeb, :controller

  alias Tbot.MessengerInput, as: MessengerInput
  alias Tbot.MessengerOutput, as: MessengerOutput

  def challenge(conn,
    %{"hub.mode" => "subscribe", "hub.verify_token" => token, "hub.challenge" => challenge}) do
    if token == verify_token do
      conn |> send_resp(200, challenge)
    else
      conn |> put_status(500)
    end
  end
  def challenge(conn, _), do: conn |> put_status(500)

  def webhook(conn, %{"entry" => entry, "object" => "page"}) do
    parsed_entry = MessengerInput.parse_messenger_entry(entry)

    # TODO: Send response in a "Task"
    body = MessengerOutput.build_request_body(parsed_entry)
    MessengerOutput.send(body)

    conn |> send_resp(200, "ok")
  end
  def webhook(conn, _),  do: conn |> put_status(500)

  defp verify_token, do: Application.get_env(:tbot, :messenger_verify_token)
end
