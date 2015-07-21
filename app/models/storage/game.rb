module Storage
  class Game < ActiveRecord::Base
    has_many :turns, dependent: :destroy
    validates :bag, presence: true
  end
end
