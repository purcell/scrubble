module Storage
  class TileUse < ActiveRecord::Base
    belongs_to :placement
    validates :letter, presence: true, length: { maximum: 1, minimum: 1 }
  end
end
