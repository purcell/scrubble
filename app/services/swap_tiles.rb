class SwapTiles
  attr_reader :game

  def initialize(game_id, tiles, player_name)
    @game_id = game_id
    @tiles = tiles
    @player_name = player_name
  end

  def call
    # TODO: locking
    @game = GameStore.load!(@game_id)
    @game.swap_tiles(@player_name, @tiles) &&
      GameStore.save_swap_tiles!(@game_id, @player_name, @tiles)
  end
end

