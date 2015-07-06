class Board
  CENTRE = Position.new(8, 8).freeze

  def initialize(dictionary)
    @dictionary = dictionary
    @tiles_by_position = {}
  end

  def empty?
    @tiles_by_position.empty?
  end

  def tile_at(position)
    @tiles_by_position[position]
  end

  def letter_at(position)
    check_position(position)
    tile_at(position).try(&:letter)
  end

  def place(placed_tile)
    check_position(placed_tile.position)
    @tiles_by_position[placed_tile.position] = placed_tile
  end

  def words
    all_words
  end

  def invalid_words
    all_words.reject(&method(:valid_word?)).map(&:to_s)
  end

  def valid_words
    all_words.select(&method(:valid_word?)).map(&:to_s)
  end

  def letter_multiplier_at(position)
    case layout_code_at(position)
    when 'd' then 2
    when 't' then 3
    else 1
    end
  end

  def word_multiplier_at(position)
    case layout_code_at(position)
    when 'D' then 2
    when 'T' then 3
    else 1
    end
  end

  private

  LAYOUT = [
    "T..d...T...d..T",
    ".D...t...t...D.",
    "..D...d.d...D..",
    "d..D...d...D..d",
    "....D.....D....",
    ".t...t...t...t.",
    "..d...d.d...d..",
    "T..d...D...d..T",
    "..d...d.d...d..",
    ".t...t...t...t.",
    "....D.....D....",
    "d..D...d...D..d",
    "..D...d.d...D..",
    ".D...t...t...D.",
    "T..d...T...d..T",
  ].freeze

  class Word < Array
    def to_s
      map(&:letter).join
    end
  end

  def layout_code_at(position)
    LAYOUT[position.y - 1][position.x - 1]
  end

  def initialize_copy(other)
    super
    @tiles_by_position = other.instance_variable_get('@tiles_by_position').dup
  end

  def all_words
    tile_positions.map do |position|
      left, up = tile_at(position.left), tile_at(position.up)
      words = []
      unless left
        words << read_word_from(position, :right)
      end
      unless up
        words << read_word_from(position, :down)
      end
      if !left && !up && !tile_at(position.right) && !tile_at(position.down)
        # Stranded letter
        words << (Word.new << tile_at(position))
      end
      words.compact
    end.inject([], :+)
  end

  def tile_positions
    @tiles_by_position.keys
  end

  def valid_word?(word)
    word.size > 1 && @dictionary.include?(word.to_s)
  end

  def read_word_from(position, direction)
    word = Word.new
    while tile = tile_at(position)
      word << tile
      position = position.send(direction)
    end
    word if word.size > 1
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
