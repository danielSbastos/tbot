defmodule Tbot.MessengerRequestData do
  @moduledoc """
  Struct that holds the POST request body sent to Messenger
  """
  defstruct message: nil, type: nil, sender_id: nil
end
