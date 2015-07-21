class CreateTileUses < ActiveRecord::Migration
  def change
    create_table :tile_uses do |t|
      t.references :turn, null: false
      t.integer :x, null: false
      t.integer :y, null: false
      t.string :letter, limit: 1, null: false
      t.boolean :blank, default: false, null: false
    end
  end
end
