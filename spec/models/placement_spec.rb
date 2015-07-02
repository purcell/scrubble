require 'rails_helper'

RSpec.describe Placement do
  let(:dictionary) { Set.new(%w(IT TO TON ETON)) }
  let(:board) { Board.new(dictionary) }
  let(:placement) { Placement.new(board) }
  let(:centre) { Board::CENTRE }

  def tile(*args)
    placement.place(PlacedTile.new(*args))
  end

  context "on an empty board" do

    it "rejects a single tile on the centre square" do
      tile("I", centre)
      expect(placement).to_not be_valid
    end

    it "allows a two-letter word spanning the centre square" do
      tile("I", centre)
      tile("T", centre.right)
      expect(placement).to be_valid
    end

    it "requires that the centre square be covered" do
      tile("I", centre.right)
      tile("T", centre.right.right)
      expect(placement).to_not be_valid
    end

    it "allows vertical words" do
      tile("I", centre)
      tile("T", centre.down)
      expect(placement).to be_valid
    end

    it "rejects tiles on a diagonal" do
      tile("I", centre)
      tile("T", centre.down.right)
      expect(placement).to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      tile("I", centre)
      tile("T", centre.right.right)
      expect(placement).to_not be_valid
    end

    it "rejects tiles placed on the same square" do
      tile("I", centre)
      tile("T", centre)
      expect(placement).to_not be_valid
    end

    it "rejects words not in the dictionary" do
      tile("Z", centre)
      tile("Q", centre.down)
      expect(placement).to_not be_valid
    end
  end

  context "on a non-empty board" do
    before do
      board.place(PlacedTile.new("T", centre))
      board.place(PlacedTile.new("O", centre.right))
    end

    it "rejects tiles placed on occupied squares" do
      tile("T", centre)
      expect(placement).to_not be_valid
    end

    it "allows tiles which extend existing words" do
      tile("N", centre.right.right)
      expect(placement).to be_valid
    end

    it "allows tiles which extend existing words at both ends" do
      tile("N", centre.right.right)
      tile("E", centre.left)
      expect(placement).to be_valid
    end

    it "adding a tile doesn't modify the original board" do
      position = centre.right.right
      tile("N", position)
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
      # TODO: this test somewhat duplicates one for PlacedTile
      ("AEILNORSTU".chars.map { |l| [l, 1] } +
       "DG".chars.map         { |l| [l, 2] } +
       "BCMP".chars.map       { |l| [l, 3] } +
       "FHVWY".chars.map      { |l| [l, 4] } +
       "K".chars.map          { |l| [l, 5] } +
       "JX".chars.map         { |l| [l, 8] } +
       "QZ".chars.map         { |l| [l, 10] }
      ).each do |letter, face_value|

        it "reports face value score for #{letter}" do
          tile(letter, centre.down)
          expect(placement.score).to eq(face_value)
        end

      end
    end

    context "with two letters placed on non-multiplier squares" do
      it "sums the face values" do
        tile("B", centre.right)
        tile("F", centre.right.right)
        expect(placement.score).to eq(3 + 4)
      end
    end

    context "with letters placed on the centre square" do
      it "doubles the word score" do
        tile("B", centre)
        tile("O", centre.right)
        tile("X", centre.right.right)
        expect(placement.score).to eq(2 * (3 + 1 + 8))
      end
    end

    context "with two letters in the corner" do
      it "triples the word score" do
        tile("A", Position.new(1, 1))
        tile("X", Position.new(2, 1))
        expect(placement.score).to eq(3 * (1 + 8))
      end
    end

    context "with letter on a double-letter square" do
      it "doubles that letter score" do
        tile("A", Position.new(3, 1))
        tile("X", Position.new(4, 1))
        expect(placement.score).to eq(1 + 2 * 8)
      end
    end

    context "with letters on multiple multiplier squares" do
      it "multiplies letters then words" do
        tile("B", Position.new(1, 1))
        tile("O", Position.new(2, 1))
        tile("A", Position.new(3, 1))
        tile("T", Position.new(4, 1))
        expect(placement.score).to eq (3 * (3 + 1 + 1 + 1 * 2))
      end

      it "compounds word multipliers" do
        tile("B", Position.new(1, 8))
        tile("O", Position.new(2, 8))
        tile("A", Position.new(3, 8))
        tile("T", Position.new(4, 8))
        tile("R", Position.new(5, 8))
        tile("I", Position.new(6, 8))
        tile("D", Position.new(7, 8))
        tile("E", Position.new(8, 8))
        expect(placement.score).to eq (3 * 2 * (3 + 1 + (1 * 2) + 1 + 1  + 1 + 2 + 1))
      end
    end

    context "with unrelated words on the board" do
      it "only scores the newly-added word" do
        board.place(PlacedTile.new("T", Position.new(3, 2)))
        board.place(PlacedTile.new("O", Position.new(4, 2)))
        tile("A", Position.new(9, 1))
        tile("T", Position.new(10, 1))
        expect(placement.score).to eq(2)
      end
    end
  end

  describe "scoring off a previously-played word" do
    context "on non-multiplier squares" do
      before do
        board.place(PlacedTile.new("T", Position.new(3, 2)))
        board.place(PlacedTile.new("O", Position.new(4, 2)))
      end

      it "scores the whole word" do
        tile("N", Position.new(5, 2))
        expect(placement.score).to eq(3)
      end
    end

    context "on word-multiplier squares" do
      before do
        board.place(PlacedTile.new("T", Position.new(2, 1)))
        board.place(PlacedTile.new("O", Position.new(3, 1)))
      end

      it "only applies new letter multipliers" do
        board.place(PlacedTile.new("E", Position.new(1, 1)))
        tile("N", Position.new(4, 1))
        expect(placement.score).to eq(5)
      end

      it "only applies new word multipliers" do
        board.place(PlacedTile.new("N", Position.new(4, 1)))
        tile("E", Position.new(1, 1))
        expect(placement.score).to eq(12)
      end
    end

  end
end
