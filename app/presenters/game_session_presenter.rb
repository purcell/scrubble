class GameSessionPresenter
  def initialize(game_id, game_session)
    @game_id = game_id
    @game_session = game_session
  end

  def as_json(options=nil)
    {
      game_id: @game_id,
      player_name: @game_session.player_name,
      board: BoardPresenter.new(@game_session.board),
      tray: @game_session.tray.tiles.map { |tile| TilePresenter.new(tile) },
      score: @game_session.score
    }
  end
end
