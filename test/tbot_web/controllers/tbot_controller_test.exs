defmodule TbotWeb.PageControllerTest do
  use TbotWeb.ConnCase

  test "GET /bot with correct verify token returns challenge token and 200", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> get("/bot", %{"hub.mode" => "subscribe", "hub.verify_token" => correct_verify_token, "hub.challenge" => "blabla"})

    assert test_conn.resp_body == correct_verify_token
    assert test_conn.status == 200
  end

  test "GET /bot with incorrect verify token returns 500", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> get("/bot", %{"hub.mode" => "subscribe", "hub.verify_token" => incorrent_verify_token, "hub.challenge" => "blabla"})

    assert test_conn.resp_body == nil
    assert test_conn.status == 500
  end

  test "GET /bot with incorrect params returns 500", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> get("/bot", %{})

    assert test_conn.resp_body == nil
    assert test_conn.status == 500
  end

  defp correct_verify_token, do: Application.get_env(:tbot, :messenger_verify_token)
  defp incorrent_verify_token, do: "não consegue, né, moisés"
end
