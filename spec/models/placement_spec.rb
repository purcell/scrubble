require 'rails_helper'

RSpec.describe Placement do
  let(:dictionary) { Set.new(%w(IT TO TON)) }
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

    it "adding a tile doesn't modify the original board" do
      position = Position.new(9, 7)
      placement.place_tile("N", position)
      expect(board.letter_at(position)).to be_nil
    end
  end

end
