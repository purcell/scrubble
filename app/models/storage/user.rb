module Storage
  class User < ActiveRecord::Base
    has_many :players, class_name: "Storage::Player"
    validates :name, presence: true, uniqueness: true
  end
end
