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
      (letters_previously_placed? || covers_centre_square?) &&
      (letters_previously_placed? || @tiles.size > 1)
  end

  def score
    letter_score = 0
    word_multiplier = 1
    @tiles.each do |tile|
      word_multiplier *= @board.word_multiplier_at(tile.position)
      letter_score += FACE_VALUES.fetch(tile.letter) * @board.letter_multiplier_at(tile.position)
    end
    letter_score * word_multiplier
  end

  private

  PlacedTile = Struct.new(:letter, :position)

  def covers_centre_square?
    positions.include?(Board::CENTRE)
  end

  def letters_previously_placed?
    !@board.empty?
  end

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
    positions.uniq == positions
  end

  def all_on_same_row?
    positions.map(&:x).uniq.size == 1
  end

  def all_on_same_column?
    positions.map(&:y).uniq.size == 1
  end

  def positions
    @tiles.map(&:position)
  end

  FACE_VALUES = Hash["AEILNORSTU".chars.map { |l| [l, 1] } +
                     "DG".chars.map         { |l| [l, 2] } +
                     "BCMP".chars.map       { |l| [l, 3] } +
                     "FHVWY".chars.map      { |l| [l, 4] } +
                     "K".chars.map          { |l| [l, 5] } +
                     "JX".chars.map         { |l| [l, 8] } +
                     "QZ".chars.map         { |l| [l, 10] }].freeze

end
