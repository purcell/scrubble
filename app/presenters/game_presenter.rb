class GamePresenter
  def initialize(game_id, game, player_name)
    @game_id = game_id
    @game = game
    @player_name = player_name
  end

  def as_json(options=nil)
    {
      game_id: @game_id,
      player_name: @player_name,
      board: BoardPresenter.new(@game.board),
      tray: @game.trays[@player_name].tiles.map { |tile| TilePresenter.new(tile) },
      score: @game.scores[@player_name]
    }
  end
end
