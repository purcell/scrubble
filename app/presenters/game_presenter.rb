class GamePresenter
  def initialize(game)
    @game = game
  end

  def as_json(options=nil)
    {
      board: BoardPresenter.new(@game.board),
      tray: @game.tray.tiles.map { |tile| TilePresenter.new(tile) },
      score: @game.score
    }
  end
end
