class Game
  attr_accessor :board
  attr_accessor :scores
  attr_reader :trays
  attr_reader :bag

  def initialize(bag, player_names)
    @bag = bag
    @scores = Hash.new(0)
    @trays = {}
    player_names.each do |name|
      @trays[name] = Tray.new(bag.draw_tiles(7))
    end
    @board = Board.new(['ROFL', 'ZOMG', 'LOLZ', 'GET', 'KIT', 'HOT', 'ROOF'])
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
end
