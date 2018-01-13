defmodule Tbot.HangmanDrawings do
  @moduledoc """
  Responsible for returning the hangman's drawings corresponding
  to each
  """
  def draw(_guess = 0) do
      """
      ________
      |      |
      |
      |
      |
      |
      """
  end

  def draw(_guess = 1) do
      """
      ________
      |      |
      |      0
      |
      |
      |
      """
  end

  def draw(_guess = 2) do
      """
      ________
      |      |
      |      0
      |     /
      |
      |
      """
  end

  def draw(_guess = 3) do
      """
      ________
      |      |
      |      0
      |     /|
      |
      |
      """
  end

  def draw(_guess = 4) do
      """
      ________
      |      |
      |      0
      |     /|\\
      |
      |
      """
  end

  def draw(_guess = 5) do
      """
      ________
      |      |
      |      0
      |     /|\\
      |     /
      |
      """
  end

  def draw(_guess = 6) do
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
