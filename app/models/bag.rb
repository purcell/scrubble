require 'simple-random'

class Bag

  def initialize(contents: full_bag_contents, random_seed: nil)
    raise ArgumentError unless contents =~ /\A[A-Z ]*\z/
    @letters = contents.chars
    @randomgen = SimpleRandom.new
    @randomgen.set_seed(random_seed) if random_seed
  end

  def draw
    @letters.shift
  end

  def draw_tile
    if letter = draw
      blank = (letter == ' ')
      Tile.new((letter unless blank), blank)
    end
  end

  def draw_tiles(n)
    n.times.map { draw_tile }.compact
  end

  def replace_tiles(tiles)
    @letters += tiles.map { |t| t.blank? ? " " : t.letter }
    shuffle!
  end

  def empty?
    size == 0
  end

  def size
    @letters.size
  end

  def contents
    @letters.join
  end

  def ==(other)
    Bag === other && other.contents == contents
  end

  private

  def shuffle!
    n = @letters.size
    0.upto(n-2).each do |i|
      j = @randomgen.uniform(i, n).floor
      @letters[j], @letters[i] = @letters[i], @letters[j]
    end
  end

  def full_bag_contents
    FREQUENCIES.map do |char, freq|
      char * freq
    end.join.chars.shuffle.join
  end

  FREQUENCIES = {
    'A' => 9,
    'B' => 2,
    'C' => 2,
    'D' => 4,
    'E' => 12,
    'F' => 2,
    'G' => 3,
    'H' => 2,
    'I' => 9,
    'J' => 1,
    'K' => 1,
    'L' => 4,
    'M' => 2,
    'N' => 6,
    'O' => 8,
    'P' => 2,
    'Q' => 1,
    'R' => 6,
    'S' => 4,
    'T' => 6,
    'U' => 4,
    'V' => 2,
    'W' => 2,
    'X' => 1,
    'Y' => 2,
    'Z' => 1,
    ' ' => 2
  }.freeze

end
