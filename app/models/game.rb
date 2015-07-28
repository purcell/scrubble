class Game
  attr_accessor :board
  attr_accessor :scores
  attr_reader :trays
  attr_reader :bag
  attr_reader :players

  def initialize(bag, players, dictionary)
    raise ArgumentError, "no players" if players.empty?
    @board = Board.new(dictionary)
    @bag = bag
    @scores = Hash.new(0)
    @trays = players.each.with_object({}) do |player, trays|
      trays[player.name] = Tray.new(bag.draw_tiles(7))
    end
    @players = players.dup
    @turns_played = 0
  end

  def current_player
    @players[@turns_played % @players.size]
  end

  def play_tiles(player, played_tiles)
    placement = Placement.new(@board)
    played_tiles.each do |pos, tile|
      placement.place(pos, tile)
    end
    if placement.valid?
      scores[player.name] += placement.score
      trays[player.name].replace_tiles(bag, placement.tiles)
      self.board = placement.new_board
      end_turn
      true
    else
      false
    end
  end

  def swap_tiles(player, tiles)
    return false if bag.size < tiles.size
    @trays[player.name].swap_tiles(bag, tiles)
    end_turn
    true
  end

  def pass_turn(player)
    end_turn
    true
  end

  private

  def end_turn
    @turns_played += 1
  end
end
