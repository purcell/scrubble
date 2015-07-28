module Storage
  class Turn < ActiveRecord::Base
    belongs_to :game, class_name: "Storage::Game"
    has_many :tile_uses, class_name: "Storage::TileUse", dependent: :destroy
    has_many :tile_swaps, class_name: "Storage::TileSwap", dependent: :destroy
    belongs_to :player, class_name: "Storage::Player"
  end
end
