class Placement
  class InvalidPlace < StandardError; end

  def initialize(board)
    @board = board
    @tiles = {}
  end

  def place(position, tile)
    if @tiles[position] || @board.letter_at(position)
      raise InvalidPlace
    end
    @tiles[position] = tile
    tile
  end

  def valid?
    @tiles.any? &&
      (all_on_same_row? || all_on_same_column?) &&
      creates_valid_words? &&
      (letters_previously_placed? || covers_centre_square?)
  end

  def score
    bonus = @tiles.size == 7 ? 50 : 0
    resulting_words.map(&method(:score_word)).inject(0, &:+) + bonus
  end

  def new_board
    @board.dup.tap do |new_board|
      @tiles.each do |position, tile|
        new_board.place(position, tile)
      end
    end
  end

  def tiles
    @tiles.values
  end

  private

  def score_word(word_tiles)
    letter_score = 0
    word_multiplier = 1
    word_tiles.each do |tile|
      letter_multiplier = 1
      # Multipliers only count for tiles we add
      if found_at = positions.find { |position| @tiles[position] == tile }
        word_multiplier *= @board.word_multiplier_at(found_at)
        letter_multiplier = @board.letter_multiplier_at(found_at)
      end
      letter_score += tile.face_value * letter_multiplier
    end
    letter_score * word_multiplier
  end

  def resulting_words
    new_board.words.select { |word_tiles| (word_tiles & @tiles.values).any? }
  end

  def covers_centre_square?
    positions.include?(Board::CENTRE)
  end

  def letters_previously_placed?
    !@board.empty?
  end

  def creates_valid_words?
    new_board.invalid_words.empty?
  end

  def all_on_same_row?
    positions.map(&:x).uniq.size == 1
  end

  def all_on_same_column?
    positions.map(&:y).uniq.size == 1
  end

  def positions
    @tiles.keys
  end
end
