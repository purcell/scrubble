class GamesController < ApplicationController

  class BoardPresenter
    Square = Struct.new(:tile, :word_multiplier, :letter_multiplier)
    def initialize(board)
      @board = board
    end

    def rows
      (1..15).map do |row|
        (1..15).map do |column|
          pos = Position.new(column, row)
          Square.new(@board.tile_at(pos),
                     @board.word_multiplier_at(pos),
                     @board.letter_multiplier_at(pos))
        end
      end
    end
  end

  class GamePresenter
    attr_reader :board

    def initialize()
      laid_out = Board.new([])
      laid_out.place(Position.new(8, 8), Tile.new("L"))
      laid_out.place(Position.new(9, 8), Tile.new("O"))
      laid_out.place(Position.new(10, 8), Tile.new("L"))
      laid_out.place(Position.new(11, 8), Tile.new("Z"))
      laid_out.place(Position.new(11, 9), Tile.new("O", true))
      laid_out.place(Position.new(11, 10), Tile.new("M"))
      laid_out.place(Position.new(11, 11), Tile.new("G"))
      @board = BoardPresenter.new(laid_out)
    end

    def tray
      "KITTEH".chars.map { |l| Tile.new(l) } + [nil]
    end
  end

  def show
    @game = GamePresenter.new()
  end

end
