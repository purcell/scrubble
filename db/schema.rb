# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150803015039) do

  create_table "games", force: :cascade do |t|
    t.string  "bag",                     null: false
    t.integer "random_seed", default: 0, null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.integer "order",   null: false
  end

  add_index "players", ["game_id", "user_id"], name: "index_players_on_game_id_and_user_id", unique: true

  create_table "tile_swaps", force: :cascade do |t|
    t.integer "turn_id",                           null: false
    t.string  "letter",  limit: 1,                 null: false
    t.boolean "blank",             default: false, null: false
  end

  create_table "tile_uses", force: :cascade do |t|
    t.integer "turn_id",                           null: false
    t.integer "x",                                 null: false
    t.integer "y",                                 null: false
    t.string  "letter",  limit: 1,                 null: false
    t.boolean "blank",             default: false, null: false
  end

  create_table "turns", force: :cascade do |t|
    t.integer "game_id",   null: false
    t.integer "player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true

end
