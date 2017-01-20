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

ActiveRecord::Schema.define(version: 20170120090736) do

  create_table "candidate_user_relations", force: :cascade do |t|
    t.integer  "candidate_id"
    t.integer  "user_id"
    t.boolean  "attend"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "attendance"
  end

  create_table "candidates", force: :cascade do |t|
    t.integer  "schedule_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "title"
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "user_type"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "source_id"
  end

  create_table "reminds", force: :cascade do |t|
    t.integer  "group_id"
    t.datetime "at"
    t.boolean  "activated",  default: false
    t.boolean  "reminded",   default: false
    t.string   "name"
    t.text     "body"
    t.string   "place"
    t.datetime "datetime"
    t.integer  "scale"
    t.string   "type"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
