defmodule Tbot.HangmanBuildDrawingTest do
  use TbotWeb.ConnCase

  alias Tbot.Redis, as: Redis
  alias Tbot.HangmanBuildDrawing, as: BuildDrawing

  setup do
    {:ok, conn} = Redix.start_link(redis_host())
    Redix.command!(conn, ["FLUSHDB"])
    Redix.stop(conn)
    :ok
  end

  setup context do
    if context[:no_setup] do
      {:ok, %{}}
    else
      {:ok, conn} = Redix.start_link(redis_host())
      {:ok, %{conn: conn}}
    end
  end

  test "first guess with correct letter", %{conn: conn} do
    sender_id = "12345"
    guess = "A"
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :correct_guesses, guess)

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

  test "third correct guess with two incorrect guesses", %{conn: conn} do
    sender_id = "12345"
    guess = "A"
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :correct_guesses, guess <> "an")
    update_redis(conn, sender_id, :incorrect_guesses, "wo")

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

  test "fifth incorrect guess with three correct guesses", %{conn: conn} do
    sender_id = "12345"
    guess = "w"
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :correct_guesses, "anA")
    update_redis(conn, sender_id, :incorrect_guesses, guess <> "pozr")

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

  test "first guess with incorrect letter", %{conn: conn} do
    sender_id = "12345"
    guess = "w"
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :incorrect_guesses, guess)

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

  test "fourth guess with incorrect letter", %{conn: conn} do
    sender_id = "12345"
    guess = "p"
    save_word_in_redis(conn, sender_id, "Anitta")
    update_redis(conn, sender_id, :incorrect_guesses, guess <> "wdb")

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

  defp save_word_in_redis(conn, sender_id, chosen_word) do
    Redis.set(conn, sender_id, :chosen_word, chosen_word)
  end

  defp update_redis(conn, sender_id, key, value) do
    Redis.set(conn, sender_id, key, value)
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
