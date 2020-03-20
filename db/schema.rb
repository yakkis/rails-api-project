# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_10_180730) do

  create_table "frames", force: :cascade do |t|
    t.string "status"
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "game_id"
    t.index ["game_id"], name: "index_frames_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "status"
    t.integer "total_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "throws", force: :cascade do |t|
    t.integer "score"
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "frame_id"
    t.index ["frame_id"], name: "index_throws_on_frame_id"
  end

  add_foreign_key "frames", "games"
  add_foreign_key "throws", "frames"
end
