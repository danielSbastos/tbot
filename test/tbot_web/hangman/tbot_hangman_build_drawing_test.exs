defmodule Tbot.HangmanBuildDrawingTest do
  use TbotWeb.ConnCase

  alias Tbot.Redis, as: Redis
  alias Tbot.HangmanBuildDrawing, as: BuildDrawing

  setup_all do
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
    save_word_in_redis(conn, "12345", "Anitta")
    update_redis(conn, "12345", :correct_guesses, "A")
    correct_drawing =
      """
      ________
      |      |
      |
      |
      |
      |
       A _ _ _ _ _
      """ <> "\nBoa! Fale mais uma letra!"

    drawing = BuildDrawing.get_drawing("A", :correct_guesses, "12345")

    assert drawing == correct_drawing
  end

  # test "third correct guess with two incorrect guesses", %{conn: conn} do
  #   save_word_in_redis(conn, "12345", "Anitta")
  #   update_redis(conn, "12345", :correct_guesses, "at")
  #   update_redis(conn, "12345", :incorrect_guesses, "wo")
  #   correct_drawing =
  #     """
  #     ________
  #     |      |
  #     |
  #     |
  #     |
  #     |
  #      A _ _ t _ a
  #     """ <> "\nBoa! Fale mais uma letra!"

  #   drawing = BuildDrawing.get_drawing("A", "12345")

  #   assert drawing == correct_drawing
  # end

  # test "fifth incorrect guess with three correct guesses", %{conn: conn} do
  #   save_word_in_redis(conn, "12345", "Anitta")
  #   update_redis(conn, "12345", :correct_guesses, "ant")
  #   update_redis(conn, "12345", :incorrect_guesses, "wozr")
  #   correct_drawing =
  #     """
  #     ________
  #     |      |
  #     |      0
  #     |     /|\\
  #     |     /
  #     |
  #      _ n _ t _ a
  #     """ <> "\nÚltima chance para acertar!"

  #   drawing = BuildDrawing.get_drawing("p", "12345")

  #   assert drawing == correct_drawing
  # end

  test "first guess with incorrect letter", %{conn: conn} do
    save_word_in_redis(conn, "12345", "Anitta")
    update_redis(conn, "12345", :incorrect_guesses, "w")
    correct_drawing =
      """
      ________
      |      |
      |      0
      |
      |
      |
       _ _ _ _ _ _
      """ <> "\nVish. Primeiro erro.."

    drawing = BuildDrawing.get_drawing("w", :incorrect_guesses, "12345")

    assert drawing == correct_drawing
  end

  # test "fourth guess with incorrect letter", %{conn: conn} do
  #   save_word_in_redis(conn, "12345", "Anitta")
  #   update_redis(conn, "12345", :incorrect_guesses, "wdb")
  #   correct_drawing =
  #     """
  #     ________
  #     |      |
  #     |      0
  #     |     /|\\
  #     |
  #     |
  #     """ <> "\nCara, o boneco vai morrer. Já errou quatro vezes."

  #   drawing = BuildDrawing.get_drawing("p", "12345")

  #   assert drawing == correct_drawing
  # end

  defp save_word_in_redis(conn, sender_id, chosen_word) do
    Redis.set(conn, sender_id, :chosen_word, chosen_word)
  end

  defp update_redis(conn, sender_id, key, value) do
    Redis.set(conn, sender_id, key, value)
  end

  defp redis_host(), do: Application.get_env(:tbot, :redis_host)
end
