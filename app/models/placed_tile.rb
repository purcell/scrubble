class PlacedTile
  attr_reader :letter, :position

  def initialize(letter, position, blank=false)
    raise(ArgumentError, "invalid letter #{letter}") unless ('A'..'Z').include?(letter)
    @letter = letter
    @position = position
    @blank = blank
  end

  def face_value
    @blank ? 0 : FACE_VALUES.fetch(letter)
  end

  private

  FACE_VALUES = Hash["AEILNORSTU".chars.map { |l| [l, 1] } +
                     "DG".chars.map         { |l| [l, 2] } +
                     "BCMP".chars.map       { |l| [l, 3] } +
                     "FHVWY".chars.map      { |l| [l, 4] } +
                     "K".chars.map          { |l| [l, 5] } +
                     "JX".chars.map         { |l| [l, 8] } +
                     "QZ".chars.map         { |l| [l, 10] }].freeze

end

