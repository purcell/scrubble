class GameSession
  def initialize(game, player)
    @game = game
    @player = player
  end

  def board
    @game.board
  end

  def player_name
    @player.name
  end

  def tray
    @game.trays[@player.name]
  end

  def score
    @game.scores[@player.name]
  end

  def play_tiles(played_tiles)
    @game.play_tiles(@player, played_tiles)
  end

  def swap_tiles(tiles)
    @game.swap_tiles(@player, tiles)
  end

  def pass_turn
    @game.pass_turn(@player)
  end
end
