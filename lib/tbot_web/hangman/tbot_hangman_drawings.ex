defmodule Tbot.HangmanDrawings do
  @moduledoc """
  Responsible for returning the hangman's drawings corresponding
  to each
  """
  def draw(_guess = 0) do
    [
      """
      ________
      |      |
      |
      |
      |
      |
      """,
      "Vamos lá! Fale a primeira letra!"
    ]
  end

  def draw(_guess = 1) do
    [
      """
      ________
      |      |
      |      0
      |
      |
      |
      """,
      "Vish. Primeiro erro.."
    ]
  end

  def draw(_guess = 2) do
    [
      """
      ________
      |      |
      |      0
      |     /
      |
      |
      """,
      "Tá piorando ein? Segundo erro já"
    ]
  end

  def draw(_guess = 3) do
    [
      """
      ________
      |      |
      |      0
      |     /|
      |
      |
      """,
      "Melhora aí, cara. Tem mais 2 tentativas..."
    ]
  end

  def draw(_guess = 4) do
    [
      """
      ________
      |      |
      |      0
      |     /|\\
      |
      |
      """,
      "Cara, o boneco vai morrer. Já errou quatro vezes."
    ]
  end

  def draw(_guess = 5) do
    [
      """
      ________
      |      |
      |      0
      |     /|\\
      |     /
      |
      """,
      "Última chance para acertar!"
    ]
  end

  def draw(_guess = 6) do
    [
      """
      ________
      |      |
      |      0
      |     /|\\
      |     / \\
      |
      """,
      "Já era. Ele morreu e você perdeu."
    ]
  end
end
