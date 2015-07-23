class CreateTileSwaps < ActiveRecord::Migration
  def change
    create_table :tile_swaps do |t|
      t.references :turn, null: false
      t.string :letter, limit: 1, null: false
      t.boolean :blank, default: false, null: false
    end
  end
end
