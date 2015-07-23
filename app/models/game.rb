class Game
  attr_accessor :board
  attr_accessor :scores
  attr_reader :trays
  attr_reader :bag

  def initialize(bag, player_names, dictionary)
    @board = Board.new(dictionary)
    @bag = bag
    @scores = Hash.new(0)
    @trays = {}
    player_names.each do |name|
      @trays[name] = Tray.new(bag.draw_tiles(7))
    end
  end

  def apply_placement(player_name, played_tiles)
    placement = Placement.new(@board)
    played_tiles.each do |pos, tile|
      placement.place(pos, tile)
    end
    if placement.valid?
      scores[player_name] += placement.score
      trays[player_name].replace_tiles(bag, placement.tiles)
      self.board = placement.new_board
      true
    else
      false
    end
  end

  def swap_tiles(player_name, tiles)
    return false if bag.size < tiles.size
    @trays[player_name].swap_tiles(bag, tiles)
    true
  end
end
