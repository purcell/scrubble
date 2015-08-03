class AddRandomSeedToGame < ActiveRecord::Migration
  def change
    add_column :games, :random_seed, :integer, null: false, default: 0
  end
end
