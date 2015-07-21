class PlayTiles
  attr_reader :game

  def initialize(game_id, played_tiles, player_name)
    @game_id = game_id
    @played_tiles = played_tiles
    @player_name = player_name
  end

  def call
    # TODO: locking
    @game = GameStore.load!(@game_id)
    @game.apply_placement(@player_name, @played_tiles).tap do |valid|
      if valid
        GameStore.save_placement!(@game_id, @played_tiles, @player_name)
      end
    end
  end
end

