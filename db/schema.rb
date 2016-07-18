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

ActiveRecord::Schema.define(version: 20160608145726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",                                                                     null: false
    t.integer  "iev_action",                                               default: 0,     null: false
    t.integer  "format",                                                                   null: false
    t.string   "file"
    t.string   "url"
    t.integer  "format_convert"
    t.string   "file_md5"
    t.integer  "status",                                                   default: 0,     null: false
    t.string   "object_id_prefix"
    t.string   "time_zone"
    t.integer  "max_distance_for_commercial",                              default: 0,     null: false
    t.boolean  "ignore_last_word",                                         default: false, null: false
    t.integer  "ignore_end_chars",                                         default: 0,     null: false
    t.integer  "max_distance_for_connection_link",                         default: 0,     null: false
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
    t.string   "short_url"
    t.string   "error_code"
    t.decimal  "file_size",                        precision: 5, scale: 2
    t.string   "filename",                                                 default: "",    null: false
    t.json     "parameters"
  end

  add_index "jobs", ["user_id"], name: "index_jobs_on_user_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "url",        null: false
    t.integer  "job_id",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "links", ["job_id"], name: "index_links_on_job_id", using: :btree

  create_table "stats", force: :cascade do |t|
    t.string   "format"
    t.string   "format_convert"
    t.string   "info"
    t.integer  "user_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.decimal  "file_size",      precision: 5, scale: 2
  end

  add_index "stats", ["user_id"], name: "index_stats_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "jobs", "users"
  add_foreign_key "links", "jobs"
  add_foreign_key "stats", "users"
end
