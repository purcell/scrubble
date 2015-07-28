module Storage
  class TileUse < ActiveRecord::Base
    belongs_to :placement, class_name: "Storage::Placement"
    validates :letter, presence: true, length: { maximum: 1, minimum: 1 }
  end
end
