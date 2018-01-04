defmodule Tbot.HangmanDrawings do
  @moduledoc """
  Responsible for returning the hangman's drawings corresponding
  to each guess
  """
  def draw(guess = 0) do
    """
    ________
    |      |
    |
    |
    |
    |
    """
  end

  def draw(guess = 1) do
    """
    ________
    |      |
    |      0
    |
    |
    |
    """
  end

  def draw(guess = 2) do
    """
    ________
    |      |
    |      0
    |     /
    |
    |
    """
  end

  def draw(guess = 3) do
    """
    ________
    |      |
    |      0
    |     /|
    |
    |
    """
  end

  def draw(guess = 4) do
    """
    ________
    |      |
    |      0
    |     /|\\
    |
    |
    """
  end

  def draw(guess = 5) do
    """
    ________
    |      |
    |      0
    |     /|\\
    |     /
    |
    """
  end

  def draw(guess = 6) do
    """
    ________
    |      |
    |      0
    |     /|\\
    |     / \\
    |
    """
  end
end
