defmodule TbotWeb.MessengerOutputTaskTest do
  use TbotWeb.ConnCase

  alias Tbot.MessengerOutputTask, as: MessengerOutputTask
  alias Tbot.MessengerRequestData, as: RequestData

  import Mock

  test "'respond_messenge' starts task to answer user" do
    with_mock HTTPotion, [post: fn(_url, _headers_and_body) -> "ok" end] do
      message_map = %RequestData{message: "hi", sender_id: "1.61803398875", type: "text"}

      task = MessengerOutputTask.respond_messenger(message_map)
      ref  = Process.monitor(task.pid)
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    end
  end
end
