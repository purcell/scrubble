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

  describe "swapping tiles" do
    let(:tiles) { [
                    Tile.new("A"), Tile.new("B"), Tile.new("B", true),
                    Tile.new("C"), Tile.new("D"), Tile.new("E"), Tile.new("F")
                  ] }
    let(:tray) { Tray.new(tiles) }

    context "when the bag is nearly empty" do
      let(:bag) { Bag.new("LMNOPQ") }

      it "refuses to swap even zero tiles" do
        expect(tray.swap_tiles(bag, [])).to eq(false)
        expect(tray.tiles).to eq(tiles)
        expect(bag).to eq(bag)
      end

      it "refuses to swap one tile" do
        expect(tray.swap_tiles(bag, [Tile.new("A")])).to eq(false)
        expect(tray.tiles).to eq(tiles)
        expect(bag).to eq(bag)
      end
    end

    context "when there are plenty of tiles" do
      let(:bag) { Bag.new("LMNOPQR") }

      it "does nothing if there are no tiles to swap" do
        expect { tray.swap_tiles(bag, []) }.to_not change { tray.tiles }
      end

      it "swaps the given tiles" do
        expect(tray.swap_tiles(bag, tiles.first(2))).to eq(true)
        expect(tray.tiles).to eq(tiles[2..-1] + [Tile.new("L"), Tile.new("M")])
      end
    end

  end

end
