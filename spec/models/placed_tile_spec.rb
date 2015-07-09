require 'rails_helper'

RSpec.describe PlacedTile do

  let(:position) { Position.new(1, 1) }

  it "allows valid letters" do
    ('A'..'Z').each do |letter|
      expect { PlacedTile.new(letter, position) }.not_to raise_error
    end
  end

  it "disallows invalid letters" do
    %w(a ? 1 &).each do |letter|
      expect { PlacedTile.new(letter, position) }.to raise_error(ArgumentError)
    end
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

      expect(PlacedTile.new(letter, position).face_value).to eq(face_value)
    end
  end

  it "reports when it is blank" do
    expect(PlacedTile.new("A", position, true)).to be_blank
    expect(PlacedTile.new("A", position)).to_not be_blank
  end

end
