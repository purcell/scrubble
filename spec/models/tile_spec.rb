require 'rails_helper'

RSpec.describe Tile do

  it "allows valid letters" do
    ('A'..'Z').each do |letter|
      expect { Tile.new(letter) }.not_to raise_error
    end
  end

  it "disallows invalid letters" do
    %w(a ? 1 &).each do |letter|
      expect { Tile.new(letter) }.to raise_error(ArgumentError)
    end
  end

  it "allows blanks" do
    expect { Tile.new(nil, true) }.not_to raise_error
  end

  it "reports its face value" do
    ("AEILNORSTU".chars.map { |l| [l, 1] } +
     "DG".chars.map         { |l| [l, 2] } +
     "BCMP".chars.map       { |l| [l, 3] } +
     "FHVWY".chars.map      { |l| [l, 4] } +
     "K".chars.map          { |l| [l, 5] } +
     "JX".chars.map         { |l| [l, 8] } +
     "QZ".chars.map         { |l| [l, 10] }
    ).each do |letter, face_value|

      expect(Tile.new(letter).face_value).to eq(face_value)
    end
  end

  it "reports when it is blank" do
    expect(Tile.new("A", true)).to be_blank
    expect(Tile.new("A")).to_not be_blank
  end

  context "when comparing tiles" do
    it "reports identical tiles as equal" do
      expect(Tile.new("A")).to eq(Tile.new("A"))
    end

    it "reports different tiles as unequal" do
      expect(Tile.new("A")).not_to eq(Tile.new("B"))
    end

    it "reports blank tiles as unequal to non-blank tiles" do
      expect(Tile.new("A")).not_to eq(Tile.new("A", true))
    end

    it "reports blank tiles as equal to other blanks with letters set" do
      expect(Tile.new("A", true)).to eq(Tile.new(nil, true))
    end
  end

end
