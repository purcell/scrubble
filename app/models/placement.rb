class Placement
  def initialize(board)
    @board = board
    @tiles = []
  end

  def place(placed_tile)
    @tiles << placed_tile
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
    resulting_words.map do |word_tiles|
      letter_score = 0
      word_multiplier = 1
      word_tiles.each do |tile|
        letter_multiplier = 1
        if @tiles.include?(tile)
          word_multiplier *= @board.word_multiplier_at(tile.position)
          letter_multiplier = @board.letter_multiplier_at(tile.position)
        end
        letter_score += tile.face_value * letter_multiplier
      end
      letter_score * word_multiplier
    end.inject(0, &:+)
  end

  private

  def resulting_words
    new_board.words.select { |word_tiles| (word_tiles & @tiles).any? }
  end

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
    new_board.invalid_words.empty?
  end

  def new_board
    @board.dup.tap do |new_board|
      @tiles.each do |tile|
        new_board.place(tile)
      end
    end
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

end
