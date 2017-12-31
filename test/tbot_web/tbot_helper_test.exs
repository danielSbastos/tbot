defmodule TbotWeb.TbotHelperTest do
  use TbotWeb.ConnCase
  import Tbot.MessengerHelper

  test "messenger entry value returns sender_id and text" do
    [sender_id, text] = ["12345", "vai malandra"]
    parsed_entry = stub_messenger_entry_value(sender_id, text) |> parse_messenger_entry

    assert parsed_entry == %{message: "vai malandra", sender_id: "12345", type: "text"}
  end

  defp stub_messenger_entry_value(sender_id, text) do
    [%{
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
  end
end
