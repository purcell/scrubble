module Storage
  class Game < ActiveRecord::Base
    has_many :turns, class_name: "Storage::Turn", dependent: :destroy
    has_many :players, class_name: "Storage::Player", dependent: :destroy
    validates :bag, presence: true
  end
end
