defmodule TbotWeb.TbotController do
  use TbotWeb, :controller
  import Tbot.MessengerHelper
  import Tbot.MessengerOutput

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
    # TODO: Transform POST body as "struct"
    parsed_entry = parse_messenger_entry(entry)

    # TODO: Send response in a "Task"
    body = build_request_body(parsed_entry)
    send(body)

    conn |> put_status(200)
  end
  def webhook(conn, _),  do: conn |> put_status(500)

  defp verify_token, do: Application.get_env(:tbot, :messenger_verify_token)
end
