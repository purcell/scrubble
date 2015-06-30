require 'rails_helper'

RSpec.describe Placement do
  let(:dictionary) { Set.new(%w(IT TO TON ETON)) }
  let(:board) { Board.new(dictionary) }
  let(:placement) { Placement.new(board) }

  context "on an empty board" do

    it "rejects a single tile on the center square" do
      placement.place_tile("I", Position.new(7, 7))
      expect(placement).to_not be_valid
    end

    it "allows a two-letter word spanning the center square" do
      placement.place_tile("I", Position.new(7, 7))
      placement.place_tile("T", Position.new(8, 7))
      expect(placement).to be_valid
    end

    it "requires that the center square be covered" do
      placement.place_tile("I", Position.new(8, 7))
      placement.place_tile("T", Position.new(9, 7))
      expect(placement).to_not be_valid
    end

    it "allows vertical words" do
      placement.place_tile("I", Position.new(7, 7))
      placement.place_tile("T", Position.new(7, 8))
      expect(placement).to be_valid
    end

    it "rejects tiles on a diagonal" do
      placement.place_tile("I", Position.new(7, 7))
      placement.place_tile("T", Position.new(8, 8))
      expect(placement).to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      placement.place_tile("I", Position.new(7, 7))
      placement.place_tile("T", Position.new(9, 7))
      expect(placement).to_not be_valid
    end

    it "rejects tiles placed on the same square" do
      placement.place_tile("I", Position.new(7, 7))
      placement.place_tile("T", Position.new(7, 7))
      expect(placement).to_not be_valid
    end

    it "rejects words not in the dictionary" do
      placement.place_tile("Z", Position.new(7, 7))
      placement.place_tile("Q", Position.new(8, 7))
      expect(placement).to_not be_valid
    end
  end

  context "on a non-empty board" do
    before do
      board.add_letter("T", Position.new(7, 7))
      board.add_letter("O", Position.new(8, 7))
    end

    it "rejects tiles placed on occupied squares" do
      placement.place_tile("T", Position.new(7, 7))
      expect(placement).to_not be_valid
    end

    it "allows tiles which extend existing words" do
      placement.place_tile("N", Position.new(9, 7))
      expect(placement).to be_valid
    end

    it "allows tiles which extend existing words at both ends" do
      placement.place_tile("N", Position.new(9, 7))
      placement.place_tile("E", Position.new(6, 7))
      expect(placement).to be_valid
    end

    it "adding a tile doesn't modify the original board" do
      position = Position.new(9, 7)
      placement.place_tile("N", position)
      expect(board.letter_at(position)).to be_nil
    end
  end

  describe "scoring" do
    context "with no letter placed" do
      it "reports a zero score" do
        expect(placement.score).to eq(0)
      end
    end

    context "with single letters placed on non-multiplier squares" do
      ("AEILNORSTU".chars.map { |l| [l, 1] } +
       "DG".chars.map { |l| [l, 2] } +
       "BCMP".chars.map { |l| [l, 3] } +
       "FHVWY".chars.map { |l| [l, 4] } +
       "K".chars.map { |l| [l, 5] } +
       "JX".chars.map { |l| [l, 8] } +
       "QZ".chars.map { |l| [l, 10] }
      ).each do |letter, face_value|

        it "reports face value score for #{letter}" do
          placement.place_tile(letter, Position.new(8, 7))
          expect(placement.score).to eq(face_value)
        end

      end
    end

    context "with two letter placed on non-multiplier squares" do
      it "sums the individual letter values" do
        placement.place_tile("B", Position.new(8, 7))
        placement.place_tile("F", Position.new(9, 7))
        expect(placement.score).to eq(3 + 4)
      end
    end
  end

end
