class GamesController < ApplicationController

  class PositionPresenter
    def initialize(position)
      @position = position
    end

    def as_json(options=nil)
      { x: @position.x, y: @position.y }
    end
  end

  class TilePresenter
    def initialize(tile)
      @tile = tile
    end

    def as_json(options=nil)
      if @tile
        { letter: @tile.letter, blank: @tile.blank?, face_value: @tile.face_value }
      end
    end
  end

  class BoardPresenter
    def initialize(board)
      @board = board
    end

    def as_json(options=nil)
      { rows: rows }
    end

    private

    def rows
      (1..15).map do |row|
        (1..15).map do |column|
          pos = Position.new(column, row)
          {
            position: PositionPresenter.new(pos),
            tile: TilePresenter.new(@board.tile_at(pos)),
            word_multiplier: @board.word_multiplier_at(pos),
            letter_multiplier: @board.letter_multiplier_at(pos)
          }.stringify_keys
        end
      end
    end
  end

  class GamePresenter
    attr_reader :board

    def initialize()
      @board = Board.new([])
      @board.place(Position.new(8, 8), Tile.new("L"))
      @board.place(Position.new(9, 8), Tile.new("O"))
      @board.place(Position.new(10, 8), Tile.new("L"))

      @board.place(Position.new(11, 8), Tile.new("Z"))
      @board.place(Position.new(11, 9), Tile.new("O", true))
      @board.place(Position.new(11, 10), Tile.new("M"))
      @board.place(Position.new(11, 11), Tile.new("G"))

      @board.place(Position.new(9, 7), Tile.new("R"))
      @board.place(Position.new(9, 9), Tile.new("F"))
      @board.place(Position.new(9, 10), Tile.new("L"))
    end

    def as_json(options=nil)
      {
        board: BoardPresenter.new(@board),
        tray: tray.map { |tile| TilePresenter.new(tile) }
      }
    end

    def tray
      "KITEH".chars.map { |l| Tile.new(l) } + [Tile.new(nil, true), nil]
    end
  end

  def show
    @game = GamePresenter.new
  end

end
