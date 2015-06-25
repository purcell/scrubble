require 'rails_helper'

RSpec.describe Placement do
  let(:board) { double("Board") }
  let(:dictionary) { Set.new(%w(IT TO TON)) }
  let(:placement) { Placement.new(board, dictionary) }

  before do
    allow(board).to receive(:letter_at).with(kind_of(Position)).and_return(nil)
  end

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
    it "rejects tiles placed on occupied squares" do
      expect(board).to receive(:letter_at).with(Position.new(7, 7)).and_return('T')
      placement.place_tile("T", Position.new(7, 7))
      placement.place_tile("O", Position.new(8, 7))
      placement.place_tile("N", Position.new(9, 7))
      expect(placement).to_not be_valid
    end

  end

end
