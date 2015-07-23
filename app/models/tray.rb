class Tray
  def initialize(tiles)
    raise ArgumentError.new if tiles.size > 7
    @tiles = tiles.dup
  end

  def replace_tiles(bag, tiles_to_remove)
    tiles_to_remove.each do |tile|
      unless i = @tiles.find_index(tile)
        raise ArgumentError, "no such tile in tray: #{tile.inspect}"
      end
      @tiles[i..i] = []
    end
    @tiles += bag.draw_tiles(tiles_to_remove.size)
  end

  def tiles
    @tiles.dup
  end
end
