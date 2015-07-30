module Storage
  class User < ActiveRecord::Base
    has_many :players, class_name: "Storage::Player"
    scope :available_to_play_with, ->(user_id) { where.not(id: user_id).order(:name) }
    validates :name, presence: true, uniqueness: true
  end
end
