Position = Struct.new(:x, :y) do
  include Comparable
  def <=>(other)
    if Position === other
      [x, y] <=> [other.x, other.y]
    end
  end

  def up
    self.class.new(x, y - 1)
  end

  def down
    self.class.new(x, y + 1)
  end

  def left
    self.class.new(x - 1, y)
  end

  def right
    self.class.new(x + 1, y)
  end
end
