require 'rails_helper'

RSpec.describe Bag do

  FREQUENCIES = {
    'A' => 9, 'B' => 2, 'C' => 2, 'D' => 4, 'E' => 12,
    'F' => 2, 'G' => 3, 'H' => 2, 'I' => 9, 'J' => 1,
    'K' => 1, 'L' => 4, 'M' => 2, 'N' => 6, 'O' => 8,
    'P' => 2, 'Q' => 1, 'R' => 6, 'S' => 4, 'T' => 6,
    'U' => 4, 'V' => 2, 'W' => 2, 'X' => 1, 'Y' => 2,
    'Z' => 1, ' ' => 2
  }.freeze

  subject(:bag) { Bag.new }

  context "when initially created" do
    it "is not empty" do
      is_expected.not_to be_empty
    end

    it "reports its size" do
      expect(bag.size).to eq(100)
    end

    it "allows a letter to be drawn" do
      drawn = bag.draw
      expect('A'..'Z' + ' ').to include(drawn)
      expect(bag.size).to eq(99)
    end

    it "allows all letters to be drawn" do
      frequencies = Hash.new(0)
      100.times do
        letter = bag.draw
        frequencies[letter] += 1
      end
      is_expected.to be_empty
      expect(frequencies).to eq(FREQUENCIES)
    end

    it "randomises the letter order" do
      srand(42)
      drawn = 100.times.map { bag.draw }.join
      expect(drawn).to eq("TNRJIIETBAEFRGVASSCGNUEIQDIYBRCLTEWAOOHDLHAYEETEODEAEIASAOIUN NILPKPOZSINL NRGXOOTIFAMEAEUVRUTEORDWM")
    end
  end

  it "can report its contents as a string" do
    srand(5150)
    expect(bag.contents).to eq(" FPACETISIIIUAIEIEIMHIOSAMETVENLRWSENPYJAATCKRGNWIOOB LDXRLGQEDRERUSNGUAOOHNNETDOTYEORAOAEFUATELZDVB")
  end

  it "can be initialized with contents" do
    contents = "ABCDEFG"
    bag = Bag.new(contents)
    contents.each_char do |letter|
      expect(bag.draw).to eq(letter)
    end
    expect(bag).to be_empty
  end

end
