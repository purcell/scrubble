require 'rails_helper'

RSpec.describe Placement do
  let(:dictionary) { Set.new(%w(IT TO TON ETON)) }
  let(:board) { Board.new(dictionary) }
  let(:placement) { Placement.new(board) }
  let(:centre) { Board::CENTRE }

  context "on an empty board" do

    it "rejects a single tile on the centre square" do
      placement.place_tile("I", centre)
      expect(placement).to_not be_valid
    end

    it "allows a two-letter word spanning the centre square" do
      placement.place_tile("I", centre)
      placement.place_tile("T", centre.right)
      expect(placement).to be_valid
    end

    it "requires that the centre square be covered" do
      placement.place_tile("I", centre.right)
      placement.place_tile("T", centre.right.right)
      expect(placement).to_not be_valid
    end

    it "allows vertical words" do
      placement.place_tile("I", centre)
      placement.place_tile("T", centre.down)
      expect(placement).to be_valid
    end

    it "rejects tiles on a diagonal" do
      placement.place_tile("I", centre)
      placement.place_tile("T", centre.down.right)
      expect(placement).to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      placement.place_tile("I", centre)
      placement.place_tile("T", centre.right.right)
      expect(placement).to_not be_valid
    end

    it "rejects tiles placed on the same square" do
      placement.place_tile("I", centre)
      placement.place_tile("T", centre)
      expect(placement).to_not be_valid
    end

    it "rejects words not in the dictionary" do
      placement.place_tile("Z", centre)
      placement.place_tile("Q", centre.down)
      expect(placement).to_not be_valid
    end
  end

  context "on a non-empty board" do
    before do
      board.add_letter("T", centre)
      board.add_letter("O", centre.right)
    end

    it "rejects tiles placed on occupied squares" do
      placement.place_tile("T", centre)
      expect(placement).to_not be_valid
    end

    it "allows tiles which extend existing words" do
      placement.place_tile("N", centre.right.right)
      expect(placement).to be_valid
    end

    it "allows tiles which extend existing words at both ends" do
      placement.place_tile("N", centre.right.right)
      placement.place_tile("E", centre.left)
      expect(placement).to be_valid
    end

    it "adding a tile doesn't modify the original board" do
      position = centre.right.right
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
          placement.place_tile(letter, centre.down)
          expect(placement.score).to eq(face_value)
        end

      end
    end

    context "with two letters placed on non-multiplier squares" do
      it "sums the face values" do
        placement.place_tile("B", centre.right)
        placement.place_tile("F", centre.right.right)
        expect(placement.score).to eq(3 + 4)
      end
    end

    context "with letters placed on the centre square" do
      it "doubles the word score" do
        placement.place_tile("B", centre)
        placement.place_tile("O", centre.right)
        placement.place_tile("X", centre.right.right)
        expect(placement.score).to eq(2 * (3 + 1 + 8))
      end
    end

    context "with two letters in the corner" do
      it "triples the word score" do
        placement.place_tile("A", Position.new(1, 1))
        placement.place_tile("X", Position.new(2, 1))
        expect(placement.score).to eq(3 * (1 + 8))
      end
    end

    context "with letter on a double-letter square" do
      it "doubles that letter score" do
        placement.place_tile("A", Position.new(3, 1))
        placement.place_tile("X", Position.new(4, 1))
        expect(placement.score).to eq(1 + 2 * 8)
      end
    end

    context "with letters on multiple multiplier squares" do
      it "multiplies letters then words" do
        placement.place_tile("B", Position.new(1, 1))
        placement.place_tile("O", Position.new(2, 1))
        placement.place_tile("A", Position.new(3, 1))
        placement.place_tile("T", Position.new(4, 1))
        expect(placement.score).to eq (3 * (3 + 1 + 1 + 1 * 2))
      end

      it "compounds word multipliers" do
        placement.place_tile("B", Position.new(1, 8))
        placement.place_tile("O", Position.new(2, 8))
        placement.place_tile("A", Position.new(3, 8))
        placement.place_tile("T", Position.new(4, 8))
        placement.place_tile("R", Position.new(5, 8))
        placement.place_tile("I", Position.new(6, 8))
        placement.place_tile("D", Position.new(7, 8))
        placement.place_tile("E", Position.new(8, 8))
        expect(placement.score).to eq (3 * 2 * (3 + 1 + (1 * 2) + 1 + 1  + 1 + 2 + 1))
      end
    end
  end

end
