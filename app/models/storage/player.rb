module Storage
  class Player < ActiveRecord::Base
    belongs_to :game, class_name: "Storage::Game"
    belongs_to :user, class_name: "Storage::User"
    validates :order, presence: true, uniqueness: { scope: :game }

    scope :with_name, ->(name) { joins(:user).merge(Storage::User.where(name: name)) }
  end
end
