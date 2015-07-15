class Tile
  attr_reader :letter

  def initialize(letter, blank=false)
    if !('A'..'Z').include?(letter) && !(blank && letter.nil?)
      raise(ArgumentError, "invalid letter #{letter}")
    end
    @letter = letter
    @blank = blank
  end

  def face_value
    @blank ? 0 : FACE_VALUES.fetch(letter)
  end

  def blank?
    @blank
  end

  def ==(other)
    (self.class === other) &&
      (blank? == other.blank?) &&
      (blank? || (letter == other.letter))
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

