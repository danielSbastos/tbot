defmodule Tbot.HangmanBuildDrawingTest do
  use TbotWeb.ConnCase

  alias Tbot.Redis, as: Redis
  alias Tbot.HangmanBuildDrawing, as: BuildDrawing

  setup do
    Redis.command(["FLUSHDB"])
    :ok
  end

  test "first guess with correct letter" do
    sender_id = "12345"
    guess = "A"
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :correct_guesses, guess)

    drawing = BuildDrawing.get_drawing(sender_id)

    correct_drawing =
      """
      ________
      |      |
      |
      |
      |
      |
       A _ _ _ _ _
      """
    assert drawing == correct_drawing
  end

  test "third correct guess with two incorrect guesses" do
    sender_id = "12345"
    guess = "A"
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :correct_guesses, guess <> "an")
    update_redis(sender_id, :incorrect_guesses, "wo")

    drawing = BuildDrawing.get_drawing(sender_id)

    correct_drawing =
      """
      ________
      |      |
      |      0
      |     /
      |
      |
       An _ _ _a
      """
    assert drawing == correct_drawing
  end

  test "fifth incorrect guess with three correct guesses" do
    sender_id = "12345"
    guess = "w"
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :correct_guesses, "anA")
    update_redis(sender_id, :incorrect_guesses, guess <> "pozr")

    drawing = BuildDrawing.get_drawing(sender_id)

    correct_drawing =
      """
      ________
      |      |
      |      0
      |     /|\\
      |     /
      |
       An _ _ _a
      """
    assert drawing == correct_drawing
  end

  test "first guess with incorrect letter" do
    sender_id = "12345"
    guess = "w"
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :incorrect_guesses, guess)

    drawing = BuildDrawing.get_drawing(sender_id)

    correct_drawing =
      """
      ________
      |      |
      |      0
      |
      |
      |
        _ _ _ _ _ _
      """
    assert drawing == correct_drawing
  end

  test "fourth guess with incorrect letter" do
    sender_id = "12345"
    guess = "p"
    save_word_in_redis(sender_id, "Anitta")
    update_redis(sender_id, :incorrect_guesses, guess <> "wdb")

    drawing = BuildDrawing.get_drawing(sender_id)

    correct_drawing =
      """
      ________
      |      |
      |      0
      |     /|\\
      |
      |
        _ _ _ _ _ _
      """
    assert drawing == correct_drawing
  end

  defp save_word_in_redis(sender_id, chosen_word) do
    Redis.set(sender_id, :chosen_word, chosen_word)
  end

  defp update_redis(sender_id, key, value) do
    Redis.set(sender_id, key, value)
  end
end
