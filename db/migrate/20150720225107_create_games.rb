class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :bag, null: false
    end
  end
end
