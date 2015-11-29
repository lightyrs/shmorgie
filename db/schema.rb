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

ActiveRecord::Schema.define(version: 20151129034549) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_stats", force: :cascade do |t|
    t.text     "api",                           null: false
    t.integer  "todays_post_count", default: 0
    t.integer  "todays_post_limit", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_stats", ["api"], name: "index_api_stats_on_api", unique: true, using: :btree

  create_table "commits", force: :cascade do |t|
    t.text     "sha"
    t.text     "user"
    t.text     "repo"
    t.text     "branch"
    t.text     "author"
    t.text     "author_email"
    t.text     "message"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reddit_submissions", force: :cascade do |t|
    t.text     "fullname"
    t.datetime "submitted_at_utc"
    t.datetime "reposted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
  end

  add_index "reddit_submissions", ["fullname"], name: "index_reddit_submissions_on_fullname", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
