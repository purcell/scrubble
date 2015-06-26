RSpec.describe Position do
  let(:position) { Position.new(7, 8) }

  it "has x and y coords" do
    expect(position.x).to eq(7)
    expect(position.y).to eq(8)
  end

  it "returns the position above" do
    expect(position.up.x).to eq(position.x)
    expect(position.up.y).to eq(position.y - 1)
  end

  it "returns the position below" do
    expect(position.down.x).to eq(position.x)
    expect(position.down.y).to eq(position.y + 1)
  end

  it "returns the position to the left" do
    expect(position.left.x).to eq(position.x - 1)
    expect(position.left.y).to eq(position.y)
  end

  it "returns the position to the right" do
    expect(position.right.x).to eq(position.x  + 1)
    expect(position.right.y).to eq(position.y)
  end

end
