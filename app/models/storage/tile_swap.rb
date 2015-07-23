module Storage
  class TileSwap < ActiveRecord::Base
    belongs_to :turn
    validates :letter, presence: true, length: { maximum: 1, minimum: 1 }
  end
end
