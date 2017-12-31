defmodule TbotWeb.TbotControllerTest do
  use TbotWeb.ConnCase

  import Mock

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

    assert test_conn.status == 500
  end

  test "GET /bot with incorrect params returns 500", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> get("/bot", %{})

    assert test_conn.status == 500
  end

  test "POST /bot with 'object': 'page' returns 200 and body", %{conn: conn} do
    with_mock HTTPotion, [post: fn(_url, _headers_and_body) -> "ok" end] do
      [sender_id | text] = ["123456", "blabla"]
      test_conn = conn
      |> put_req_header("accept", "application/json")
      |> post("/bot", stub_post_messenger(sender_id, text))

      assert test_conn.status == 200
    end
  end

  test "POST /bot without 'object': 'page' returns 500", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> post("/bot", %{"object" => "not page", "entry": "not important"})

    assert test_conn.status == 500
  end

  test "POST /bot with no body returns 500", %{conn: conn} do
    test_conn = conn
    |> put_req_header("accept", "application/json")
    |> post("/bot", %{})

    assert test_conn.status == 500
  end

  defp correct_verify_token, do: Application.get_env(:tbot, :messenger_verify_token)
  defp incorrent_verify_token, do: "não consegue, né, moisés"
  defp stub_post_messenger(sender_id, text) do
    %{
      "object" => "page",
      "entry" => [%{
        "id" => "1231930516917414",
        "time" => "1500408432080",
        "messaging" => [%{
          "sender" => %{"id" => sender_id},
          "recipient" => %{"id" => "1231930516917414"},
          "timestamp" => "1500408431958",
          "message" => %{
            "mid" => "mid.$cAAQ6nOh9tL9jiJUNVldV0_Eirk_R",
            "seq" => "30259",
            "text" => text,
          }
        }]
      }]
    }
  end
end
