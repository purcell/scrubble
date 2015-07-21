module Storage
  class Turn < ActiveRecord::Base
    belongs_to :game
    has_many :tile_uses, dependent: :destroy
    validates :player_name, presence: true
  end
end
