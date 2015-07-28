# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Storage::Game.transaction do

  users = %w(Steve Bob Alice).map do |name|
    Storage::User.create!(name: name)
  end

  Storage::Game.create!(bag: "ZOMGKITTEHROFLLOLZGETGETASKIOIOZXCJLKJQOWIJLKJASDSAD",
                        players: users.map.with_index do |u, i|
                          Storage::Player.new(user: u, order: i)
                        end)


end
