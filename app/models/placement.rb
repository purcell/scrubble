class Placement
  def initialize(board)
    @board = board
    @tiles = []
  end

  def place_tile(letter, position)
    @tiles << PlacedTile.new(letter, position)
  end

  def valid?
    return false if @tiles.empty?
    return false if any_on_occupied_squares?
    return false if duplicate_positions?
    return false unless (all_on_same_row? || all_on_same_column?)
    return false if any_gaps?
    return false unless creates_valid_words?
    if @board.empty?
      return false unless sorted_positions.include?(CENTRE)
      return @tiles.size > 1
    end
    true
  end

  private

  CENTRE = Position.new(7, 7)

  PlacedTile = Struct.new(:letter, :position)

  def any_on_occupied_squares?
    @tiles.map(&:position).any? { |pos| @board.letter_at(pos)}
  end

  def creates_valid_words?
    new_board = @board.dup
    @tiles.each do |tile|
      new_board.add_letter(tile.letter, tile.position)
    end
    new_board.invalid_words.empty?
  end

  def any_gaps?
    positions = sorted_positions
    (positions.map(&:x).uniq != (positions.first.x..positions.last.x).to_a) ||
      (positions.map(&:y).uniq != (positions.first.y..positions.last.y).to_a)
  end

  def duplicate_positions?
    positions = sorted_positions
    positions.uniq != sorted_positions
  end

  def all_on_same_row?
    sorted_positions.map(&:x).uniq.size == 1
  end

  def all_on_same_column?
    sorted_positions.map(&:y).uniq.size == 1
  end

  def tiles_sorted_by_position
    @tiles.sort_by(&:position)
  end

  def sorted_positions
    tiles_sorted_by_position.map(&:position)
  end
end
