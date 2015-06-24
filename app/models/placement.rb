class Placement
  def initialize(grid, dictionary)
    @tiles = []
  end

  def place_tile(tile, x, y)
    @tiles << [tile, Position.new(x, y)]
  end

  def valid?
    return false if @tiles.empty?
    return false unless (all_on_same_row? || all_on_same_column?)
    return false unless sorted_positions.include?(CENTRE)
    return false if any_gaps?
    @tiles.size > 1
  end

  private

  Position = Struct.new(:x, :y) do
    include Comparable
    def <=>(other)
      [x, y] <=> [other.x, other.y]
    end
  end
  CENTRE = Position.new(7, 7)

  def any_gaps?
    positions = sorted_positions
    (positions.map(&:x).uniq != (positions.first.x..positions.last.x).to_a) ||
      (positions.map(&:y).uniq != (positions.first.y..positions.last.y).to_a)
  end

  def all_on_same_row?
    x_coords.uniq.size == 1
  end

  def all_on_same_column?
    y_coords.uniq.size == 1
  end

  def sorted_positions
    @tiles.map { |tile, pos| pos }.sort
  end

  def x_coords
    @tiles.map { |tile, pos| pos.x }
  end

  def y_coords
    @tiles.map { |tile, pos| pos.y }
  end
end
