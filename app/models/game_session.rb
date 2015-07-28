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

  def turn_player_name
    @game.current_player.name
  end

  def my_turn?
    @game.current_player == @player
  end

  def tray
    @game.trays[@player.name]
  end

  def scores
    @game.players.map { |p| [p.name, @game.scores[p.name]] }
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
