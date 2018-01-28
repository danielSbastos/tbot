defmodule Tbot.SyncUserChosenWord do
  @moduledoc """
  Module responsbile for fetching a random word, translating it to portuguese
  and saving in Redis with the set name as the sender_id and the word as one
  of the values
  """
  alias Tbot.HangmanWord
  alias Tbot.Redis
  alias Tbot.Agent

  def sync(magic_map) do
    conn = Redis.start_link

    # You can alter the function below and use word_from_api() instead.
    word = word_from_file

    Agent.start_link
    Agent.update(magic_map.sender_id, :first_interaction)

    Redis.set(conn, magic_map.sender_id, :chosen_word, word)
  end

  defp word_from_file() do
    word_list = word_file_content |> String.split |> Enum.drop(-1)
    random_list_index = Enum.random(0..(length(word_list) -1))
    Enum.at(word_list, random_list_index)
  end

  defp word_from_api() do
    HangmanWord.fetch_random_english_word |> HangmanWord.translate_to_portuguese
  end

  defp word_file_content() do
    file = Path.join(System.cwd, "/lib/tbot_web/data/word_list.txt")
    {:ok, pid} = File.open(file)
    {:ok, content} = File.read(file)
    File.close(pid)
    content
  end
end
