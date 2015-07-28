class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other)
    self.class === other && name == other.name
  end
end
