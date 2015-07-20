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
