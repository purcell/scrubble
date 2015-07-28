class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :game, null: false
      t.references :user, null: false
      t.integer :order, null: false
    end
    add_index :players, [:game_id, :user_id], unique: true
  end
end
