class CreateTurns < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.string :player_name, null: false
      t.references :game, null: false
    end
  end
end
