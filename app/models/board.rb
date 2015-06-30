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
    all_words.select(&method(:bad_word?)) + stranded_letters
  end

  def valid_words
    all_words.reject(&method(:bad_word?))
  end

  def word_multiplier_at(position)
    position == CENTRE ? 2 : 1
  end

  private

  def stranded_letters
    letter_positions.inject([]) do |stranded, position|
      letter = letter_at(position)
      stranded << letter if letter && !has_neighbours?(position)
      stranded
    end
  end

  def has_neighbours?(position)
    letter_at(position.left) ||
      letter_at(position.right) ||
      letter_at(position.up) ||
      letter_at(position.down)
  end

  def initialize_copy(other)
    super
    @letters = other.instance_variable_get('@letters').dup
  end

  def all_words
    letter_positions.map do |start_position|
      rightwards = read_word_from(start_position, :right) unless letter_at(start_position.left)
      downwards = read_word_from(start_position, :down) unless letter_at(start_position.up)
      [rightwards, downwards].compact.reject { |word| word.size == 1 }
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
    !@dictionary.include?(word)
  end

  def read_word_from(position, direction)
    letters = []
    while letter = letter_at(position)
      letters << letter
      position = position.send(direction)
    end
    letters.join('')
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
