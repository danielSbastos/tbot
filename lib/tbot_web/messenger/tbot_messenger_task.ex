defmodule Tbot.MessengerOutputTask do
  @moduledoc """
  Task responsible for building the Messenger resquest body and
  sending it back to Messenger's user.
  """

  alias Tbot.MessengerOutput

  def respond_messenger(parsed_entry) do
    Task.Supervisor.async_nolink Tbot.TaskSupervisor, fn ->
      body = MessengerOutput.build_request_body(parsed_entry)
      MessengerOutput.send(body)
    end
  end
end
