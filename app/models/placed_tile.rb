class PlacedTile
  attr_reader :letter, :position

  def initialize(letter, position)
    raise(ArgumentError, "invalid letter #{letter}") unless ('A'..'Z').include?(letter)
    @letter = letter
    @position = position
  end

  def face_value
    FACE_VALUES.fetch(letter)
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

