require 'rails_helper'

RSpec.describe Placement do
  let(:dictionary) { Set.new(%w(IT TO TON ETON)) }
  let(:board) { Board.new(dictionary) }
  let(:centre) { Board::CENTRE }

  subject(:placement) { Placement.new(board) }

  def place(position, *tileargs)
    placement.place(position, Tile.new(*tileargs))
  end

  def board_has(position, *tileargs)
    board.place(position, Tile.new(*tileargs))
  end

  context "on an empty board" do

    it "rejects a single tile on the centre square" do
      place(centre, "I")
      is_expected.to_not be_valid
    end

    it "allows a two-letter word spanning the centre square" do
      place(centre, "I")
      place(centre.right, "T")
      is_expected.to be_valid
    end

    it "requires that the centre square be covered" do
      place(centre.right, "I")
      place(centre.right.right, "T")
      is_expected.to_not be_valid
    end

    it "allows vertical words" do
      place(centre, "I")
      place(centre.down, "T")
      is_expected.to be_valid
    end

    it "rejects tiles on a diagonal" do
      place(centre, "I")
      place(centre.down.right, "T")
      is_expected.to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      place(centre, "I")
      place(centre.right.right, "T")
      is_expected.to_not be_valid
    end

    it "rejects tiles placed on the same square" do
      place(centre, "I")
      expect { place(centre, "T") }.to raise_error(Placement::InvalidPlace)
    end

    it "rejects words not in the dictionary" do
      place(centre, "Z")
      place(centre.down, "Q")
      is_expected.to_not be_valid
    end
  end

  context "on a non-empty board" do
    before do
      board_has(centre, "T")
      board_has(centre.right, "O")
    end

    it "rejects tiles placed on occupied squares" do
      expect { place(centre, "T") }.to raise_error(Placement::InvalidPlace)
    end

    it "allows tiles which extend existing words" do
      place(centre.right.right, "N")
      is_expected.to be_valid
    end

    it "allows tiles which extend existing words at both ends" do
      place(centre.right.right, "N")
      place(centre.left, "E")
      is_expected.to be_valid
    end

    it "adding a tile doesn't modify the original board" do
      position = centre.right.right
      place(position, "N")
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
      ("A".."Z").each do |letter|
        it "reports face value score for #{letter}" do
          tile = place(centre.down, letter)
          expect(placement.score).to eq(tile.face_value)
        end
      end
    end

    context "with two letters placed on non-multiplier squares" do
      it "sums the face values" do
        place(centre.right, "B")
        place(centre.right.right, "F")
        expect(placement.score).to eq(3 + 4)
      end
    end

    context "with letters placed on the centre square" do
      it "doubles the word score" do
        place(centre, "B")
        place(centre.right, "O")
        place(centre.right.right, "X")
        expect(placement.score).to eq(2 * (3 + 1 + 8))
      end
    end

    context "with two letters in the corner" do
      it "triples the word score" do
        place(Position.new(1, 1), "A")
        place(Position.new(2, 1), "X")
        expect(placement.score).to eq(3 * (1 + 8))
      end
    end

    context "with letter on a double-letter square" do
      it "doubles that letter score" do
        place(Position.new(3, 1), "A")
        place(Position.new(4, 1), "X")
        expect(placement.score).to eq(1 + 2 * 8)
      end
    end

    context "with letters on multiple multiplier squares" do
      it "multiplies letters then words" do
        place(Position.new(1, 1), "B")
        place(Position.new(2, 1), "O")
        place(Position.new(3, 1), "A")
        place(Position.new(4, 1), "T")
        expect(placement.score).to eq (3 * (3 + 1 + 1 + 1 * 2))
      end

      it "compounds word multipliers" do
        place(Position.new(1, 8), "B")
        place(Position.new(2, 8), "O")
        place(Position.new(3, 8), "A")
        place(Position.new(4, 8), "T")
        place(Position.new(5, 8), "R")
        place(Position.new(6, 8), "I")
        place(Position.new(7, 8), "D")
        place(Position.new(8, 8), "E")
        expect(placement.score).to eq (3 * 2 * (3 + 1 + (1 * 2) + 1 + 1  + 1 + 2 + 1))
      end
    end

    context "with unrelated words on the board" do
      it "only scores the newly-added word" do
        board_has(Position.new(3, 2), "T")
        board_has(Position.new(4, 2), "O")
        place(Position.new(9, 1), "A")
        place(Position.new(10, 1), "T")
        expect(placement.score).to eq(2)
      end
    end
  end

  describe "scoring off a previously-played word" do
    context "on non-multiplier squares" do
      before do
        board_has(Position.new(3, 2), "T")
        board_has(Position.new(4, 2), "O")
      end

      it "scores the whole word" do
        place(Position.new(5, 2), "N")
        expect(placement.score).to eq(3)
      end
    end

    context "on word-multiplier squares" do
      before do
        board_has(Position.new(2, 1), "T")
        board_has(Position.new(3, 1), "O")
      end

      it "only applies new letter multipliers" do
        board_has(Position.new(1, 1), "E")
        place(Position.new(4, 1), "N")
        expect(placement.score).to eq(5)
      end

      it "only applies new word multipliers" do
        board_has(Position.new(4, 1), "N")
        place(Position.new(1, 1), "E")
        expect(placement.score).to eq(12)
      end
    end

  end

  context "when playing blank tiles" do
    it "counts the letter score as 0" do
      place(Position.new(2, 1), "A")
      place(Position.new(3, 1), "X", true)
      expect(placement.score).to eq(1)
    end
  end

  context "when playing blanks on a word multiplier" do
    it "still applies the multiplier" do
      place(Position.new(1, 1), "A", true)
      place(Position.new(2, 1), "X")
      expect(placement.score).to eq(24)
    end
  end

  context "when blanks were previously played" do
    it "counts the letter score as 0" do
      board_has(Position.new(2, 1), "A", true)
      place(Position.new(3, 1), "X")
      expect(placement.score).to eq(8)
    end
  end
end
