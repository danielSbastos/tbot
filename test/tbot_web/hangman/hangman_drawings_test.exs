defmodule Tbot.HangmanDrawingsTest do
  use TbotWeb.ConnCase

  alias Tbot.HangmanDrawings, as: HangmanDrawings

  test "'draw' returns correct drawing given a guess number" do
    drawing_three = HangmanDrawings.draw(3)
    drawing_five = HangmanDrawings.draw(5)

    assert drawing_five == fifth_drawing
    assert drawing_three == third_drawing
  end

  defp third_drawing do
    """
    ________
    |      |
    |      0
    |     /|
    |
    |
    """
  end

  def fifth_drawing do
    """
    ________
    |      |
    |      0
    |     /|\\
    |     /
    |
    """
  end
end
