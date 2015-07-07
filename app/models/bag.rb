class Bag

  def initialize(letters=fresh_contents)
    @letters = letters.chars
  end

  def draw
    @letters.shift
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

  private

  def fresh_contents
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