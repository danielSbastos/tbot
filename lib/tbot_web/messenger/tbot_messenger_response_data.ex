defmodule Tbot.MessengerResponseData do
  @moduledoc """
  Struct that holds the sent message from the Messenger's user, its
  type (quick reply, postback or text) and the their sender_id
  """
  defstruct message: nil, recipient: nil
end
