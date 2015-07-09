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
      laid_out.place(PlacedTile.new("L", Position.new(8, 8)))
      laid_out.place(PlacedTile.new("O", Position.new(9, 8)))
      laid_out.place(PlacedTile.new("L", Position.new(10, 8)))
      laid_out.place(PlacedTile.new("Z", Position.new(11, 8)))
      laid_out.place(PlacedTile.new("O", Position.new(11, 9), true))
      laid_out.place(PlacedTile.new("M", Position.new(11, 10)))
      laid_out.place(PlacedTile.new("G", Position.new(11, 11)))
      @board = BoardPresenter.new(laid_out)
    end
  end

  def show
    @game = GamePresenter.new()
  end

end