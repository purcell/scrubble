module Storage
  class Game < ActiveRecord::Base
    has_many :turns, class_name: "Storage::Turn", dependent: :destroy
    has_many :players, class_name: "Storage::Player", dependent: :destroy
    validates :bag, presence: true
    validates :random_seed, presence: true
  end
end
