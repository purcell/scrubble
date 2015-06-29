class Placement
  def initialize(board)
    @board = board
    @tiles = []
  end

  def place_tile(letter, position)
    @tiles << PlacedTile.new(letter, position)
  end

  def valid?
    @tiles.any? &&
      all_on_free_squares? &&
      distinct_positions? &&
      (all_on_same_row? || all_on_same_column?) &&
      creates_valid_words? &&
      if @board.empty?
        sorted_positions.include?(CENTRE) && @tiles.size > 1
      else
        true
      end
  end

  private

  CENTRE = Position.new(7, 7)

  PlacedTile = Struct.new(:letter, :position)

  def all_on_free_squares?
    @tiles.map(&:position).all? { |pos| @board.letter_at(pos).nil?}
  end

  def creates_valid_words?
    new_board = @board.dup
    @tiles.each do |tile|
      new_board.add_letter(tile.letter, tile.position)
    end
    new_board.invalid_words.empty?
  end

  def distinct_positions?
    positions = sorted_positions
    positions.uniq == sorted_positions
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
