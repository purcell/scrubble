RSpec.describe Tray do

  context "when creating" do

    it "complains when there are too many tiles" do
      expect { Tray.new(8.times.map { Tile.new("A") }) }.to raise_error(ArgumentError)
    end

    it "allows 7 tiles" do
      expect { Tray.new(7.times.map { Tile.new("A") }) }.not_to raise_error
    end

    it "allows the initial tiles to be accessed" do
      tiles = [Tile.new("A"), Tile.new("B"), Tile.new("C")]
      expect(Tray.new(tiles).tiles).to eq(tiles)
    end
  end

  context "when replacing tiles" do
    let(:tiles) { [Tile.new("A"), Tile.new("B"), Tile.new("B", true), Tile.new("C")] }
    let(:tray) { Tray.new(tiles) }
    let(:bag) { Bag.new("XY") }

    it "removes matching tiles" do
      tray.replace_tiles(bag, [Tile.new("B"), Tile.new("C")])
      expect(bag).to be_empty
      expect(tray.tiles).to eq([Tile.new("A"), Tile.new("B", true), Tile.new("X"), Tile.new("Y")])
    end

    it "complains when those tiles were not present" do
      expect { tray.replace_tiles(bag, [Tile.new("K")]) }.to raise_error(ArgumentError)
    end
  end

end
