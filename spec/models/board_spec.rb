require 'rails_helper'

RSpec.describe Board do
  let(:dictionary) { Set.new(%w(IT TO DO FIT)) }
  let(:board) { Board.new(dictionary) }

  def place(*placed_tile)
    board.place(PlacedTile.new(*placed_tile))
  end

  context "when board is empty" do
    it "reports that all squares are empty" do
      (1..15).each do |x|
        (1..15).each do |y|
          expect(board.letter_at(Position.new(x, y))).to eq(nil)
        end
      end
      expect(board).to be_empty
    end

    it "complains about invalid positions" do
      [[0, 0], [0, 1], [1, 0], [16, 1], [1, 16]].each do |coords|
        expect { board.letter_at(Position.new(*coords)) }.to raise_error(ArgumentError)
      end
    end

    it "can have a letter added" do
      place("A", Position.new(7, 7))
      expect(board.letter_at(Position.new(7, 7))).to eq("A")
    end

    it "reports no words as either valid or invalid" do
      expect(board.invalid_words).to be_empty
      expect(board.valid_words).to be_empty
    end
  end

  context "when duplicating a board" do
    it "doesn't affect the original board when a letter is added to the duplicate" do
      board2 = board.dup
      board2.place(PlacedTile.new("Z", Position.new(4, 4)))
      expect(board.letter_at(Position.new(4, 4))).to be_nil
    end
  end

  context "when there's a single letter" do
    it "reports that word as invalid" do
      place("A", Position.new(7, 7))
      expect(board.valid_words).to be_empty
      expect(board.invalid_words).to eq(["A"])
    end
  end

  context "when there's an invalid word" do
    it "reports that word as invalid" do
      place("A", Position.new(7, 7))
      place("Z", Position.new(8, 7))
      expect(board.invalid_words).to eq(["AZ"])
      expect(board.valid_words).to be_empty
    end
  end

  context "when there's an existing valid word" do
    before do
      place("I", Position.new(7, 7))
      place("T", Position.new(8, 7))
    end

    it "lists that word as valid" do
      expect(board.valid_words).to eq(["IT"])
      expect(board.invalid_words).to be_empty
    end

    it "allows that word to be extended perpendicularly" do
      place("O", Position.new(8, 8))
      expect(board.valid_words).to eq(%w(IT TO))
      expect(board.invalid_words).to be_empty
    end

    it "allows that word to be extended horizontally" do
      place("F", Position.new(6, 7))
      expect(board.valid_words).to eq(%w(FIT))
      expect(board.invalid_words).to be_empty
    end
  end

  describe "word multiplier squares" do
    it "reports the multiplier of a plain square as 1" do
      expect(board.word_multiplier_at(Board::CENTRE.right)).to eql(1)
    end

    it "reports the middle square as a double word" do
      expect(board.word_multiplier_at(Board::CENTRE)).to eql(2)
    end

    it "reports only the correct diagonal squares as double words" do
      (1..15).map do |x|
        (1..15).map do |y|
          position = Position.new(x, y)
          multiplier = board.word_multiplier_at(position)
          if ([x, 15 - x + 1].include?(y)) && [2,3,4,5,8,11,12,13,14].include?(x)
            expect(multiplier).to eql(2)
          else
            expect(multiplier).not_to eql(2)
          end
        end
      end
    end

    it "reports only the correct squares as triple words" do
      (1..15).map do |x|
        (1..15).map do |y|
          position = Position.new(x, y)
          multiplier = board.word_multiplier_at(position)
          if [1, 8, 15].include?(x) && [1, 8, 15].include?(y) && [x, y] != [8, 8]
            expect(multiplier).to eql(3)
          else
            expect(multiplier).not_to eql(3)
          end
        end
      end
    end
  end

  describe "letter multiplier squares" do
    it "reports the letter multiplier as 1 for plain squares" do
      expect(board.letter_multiplier_at(Position.new(2, 1))).to eq(1)
      expect(board.letter_multiplier_at(Position.new(7, 8))).to eq(1)
    end

    it "reports the letter multiplier as 2 for double-letter squares" do
      expect(board.letter_multiplier_at(Position.new(4, 1))).to eq(2)
      expect(board.letter_multiplier_at(Position.new(8, 12))).to eq(2)
    end

    it "reports the letter multiplier as 3 for triple-letter squares" do
      expect(board.letter_multiplier_at(Position.new(6, 2))).to eq(3)
      expect(board.letter_multiplier_at(Position.new(14, 10))).to eq(3)
    end
  end

end
