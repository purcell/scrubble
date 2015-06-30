class Board
  CENTRE = Position.new(8, 8).freeze

  def initialize(dictionary)
    @dictionary = dictionary
    @letters = {}
  end

  def empty?
    @letters.empty?
  end

  def letter_at(position)
    check_position(position)
    @letters[position]
  end

  def add_letter(letter, position)
    @letters[position] = letter
  end

  def invalid_words
    all_words.select(&method(:bad_word?))
  end

  def valid_words
    all_words.reject(&method(:bad_word?))
  end

  def word_multiplier_at(position)
    if double_word?(position)
      2
    elsif triple_word?(position)
      3
    else
      1
    end
  end

  private

  def initialize_copy(other)
    super
    @letters = other.instance_variable_get('@letters').dup
  end

  def all_words
    letter_positions.map do |position|
      left, up = letter_at(position.left), letter_at(position.up)
      words = []
      unless left
        words << read_word_from(position, :right)
      end
      unless up
        words << read_word_from(position, :down)
      end
      if !left && !up && !letter_at(position.right) && !letter_at(position.down)
        # Stranded letter
        words << letter_at(position)
      end
      words.compact
    end.flatten
  end

  def positions_from_top_left
    Enumerator.new do |enum|
      coord_range.each do |x|
        coord_range.each do |y|
          enum << Position.new(x, y)
        end
      end
    end
  end

  def letter_positions
    positions_from_top_left.find_all { |position| letter_at(position) }
  end

  def bad_word?(word)
    word.size == 1 || !@dictionary.include?(word)
  end

  def read_word_from(position, direction)
    letters = []
    while letter = letter_at(position)
      letters << letter
      position = position.send(direction)
    end
    letters.join('') if letters.size > 1
  end

  def double_word?(position)
    ([position.x, 15 - position.x + 1].include?(position.y)) &&
      [2,3,4,5,8,10,11,12,13].include?(position.x)
  end

  def triple_word?(position)
    ([1, 8, 15].include?(position.x) &&
     [1, 8, 15].include?(position.y) &&
     position != CENTRE)
  end

  def check_position(position)
    unless coord_range.include?(position.x) && coord_range.include?(position.y)
      raise ArgumentError, "invalid position"
    end
  end

  def coord_range
    1..15
  end
end
