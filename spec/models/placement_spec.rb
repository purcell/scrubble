require 'rails_helper'

RSpec.describe Placement do

  class Grid
  end
  class Tile
    def initialize(letter)
    end
  end

  context "on an empty board" do
    let(:grid) { Grid.new }
    let(:dictionary) { Set.new(["IT"]) }
    let(:placement) { Placement.new(grid, dictionary) }

    it "rejects a single tile on the center square" do
      placement.place_tile("I", 7, 7)
      expect(placement).to_not be_valid
    end

    it "allows a two-letter word spanning the center square" do
      placement.place_tile("I", 7, 7)
      placement.place_tile("T", 8, 7)
      expect(placement).to be_valid
    end

    it "requires that the center square be covered" do
      placement.place_tile("I", 8, 7)
      placement.place_tile("T", 9, 7)
      expect(placement).to_not be_valid
    end

    it "allows vertical words" do
      placement.place_tile("I", 7, 7)
      placement.place_tile("T", 7, 8)
      expect(placement).to be_valid
    end

    it "rejects tiles on a diagonal" do
      placement.place_tile("I", 7, 7)
      placement.place_tile("T", 8, 8)
      expect(placement).to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      placement.place_tile("I", 7, 7)
      placement.place_tile("T", 9, 7)
      expect(placement).to_not be_valid
    end

    it "rejects tiles placed on the same square" do
      placement.place_tile("I", 7, 7)
      placement.place_tile("T", 7, 7)
      expect(placement).to_not be_valid
    end

    it "rejects words not in the dictionary" do
      placement.place_tile("Z", 7, 7)
      placement.place_tile("Q", 8, 7)
      expect(placement).to_not be_valid
    end
  end

end
