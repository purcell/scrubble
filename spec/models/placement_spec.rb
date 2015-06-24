require 'rails_helper'

RSpec.describe Placement do

  class Grid
  end
  class Tile
    def initialize(letter)
    end
  end

  context "with an empty board" do
    let(:grid) { Grid.new }
    let(:dictionary) { Set.new(["it"]) }
    let(:placement) { Placement.new(grid, dictionary) }

    it "rejects a single tile on the center square" do
      placement.place_tile(Tile.new("I"), 7, 7)
      expect(placement).to_not be_valid
    end

    it "allows a two-letter word spanning the center square" do
      placement.place_tile(Tile.new("I"), 7, 7)
      placement.place_tile(Tile.new("T"), 8, 7)
      expect(placement).to be_valid
    end

    it "requires that the center square be covered" do
      placement.place_tile(Tile.new("I"), 8, 7)
      placement.place_tile(Tile.new("T"), 9, 7)
      expect(placement).to_not be_valid
    end

    it "allows vertical words" do
      placement.place_tile(Tile.new("I"), 7, 7)
      placement.place_tile(Tile.new("T"), 7, 8)
      expect(placement).to be_valid
    end

    it "rejects tiles on a diagonal" do
      placement.place_tile(Tile.new("I"), 7, 7)
      placement.place_tile(Tile.new("T"), 8, 8)
      expect(placement).to_not be_valid
    end

    it "rejects non-contiguous tiles" do
      placement.place_tile(Tile.new("I"), 7, 7)
      placement.place_tile(Tile.new("T"), 9, 7)
      expect(placement).to_not be_valid
    end

    # prevent invalid words

    # prevent placing two tiles on the same square
  end

end
