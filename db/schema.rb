# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_18_114310) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "status", default: 1, null: false
    t.citext "email", null: false
    t.string "password_hash"
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "(status = ANY (ARRAY[1, 2]))"
    t.check_constraint "email ~ '^[^,;@ \r\n]+@[^,@; \r\n]+.[^,@; \r\n]+$'::citext", name: "valid_email"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_attributes", force: :cascade do |t|
    t.bigint "family_member_id", null: false
    t.string "attribute_name", limit: 150, null: false
    t.string "long_text", limit: 2000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_member_id"], name: "index_additional_attributes_on_family_member_id"
  end

  create_table "educations", force: :cascade do |t|
    t.bigint "family_member_id", null: false
    t.string "school_name", limit: 250, null: false
    t.string "address", limit: 250
    t.string "period", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_member_id"], name: "index_educations_on_family_member_id"
  end

  create_table "employments", force: :cascade do |t|
    t.bigint "family_member_id", null: false
    t.string "employer", limit: 250, null: false
    t.string "address", limit: 250
    t.string "period", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_member_id"], name: "index_employments_on_family_member_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_families_on_account_id"
    t.index ["uuid"], name: "index_families_on_uuid", unique: true
  end

  create_table "family_members", force: :cascade do |t|
    t.string "first_name", limit: 100, null: false
    t.string "last_name", limit: 100, null: false
    t.date "date_of_birth"
    t.date "date_of_death"
    t.bigint "family_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "birth_last_name", limit: 100
    t.string "birth_place", limit: 250
    t.time "birth_time"
    t.integer "gender"
    t.string "religion", limit: 100
    t.boolean "deceased", default: false
    t.time "death_time"
    t.string "death_place", limit: 250
    t.string "cause_of_death", limit: 100
    t.date "burial_date"
    t.string "burial_place", limit: 250
    t.string "internment_place", limit: 250
    t.bigint "mother_id"
    t.bigint "father_id"
    t.string "profession", limit: 1000
    t.string "hobbies_and_interests", limit: 1000
    t.string "short_description", limit: 2000
    t.string "short_message", limit: 2000
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["father_id"], name: "index_family_members_on_father_id"
    t.index ["mother_id"], name: "index_family_members_on_mother_id"
  end

  create_table "family_members_stories", id: false, force: :cascade do |t|
    t.bigint "story_id", null: false
    t.bigint "family_member_id", null: false
    t.index ["family_member_id"], name: "index_family_members_stories_on_family_member_id"
    t.index ["story_id"], name: "index_family_members_stories_on_story_id"
  end

  create_table "marriages", force: :cascade do |t|
    t.bigint "first_partner_id", null: false
    t.bigint "second_partner_id", null: false
    t.string "period", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_partner_id"], name: "index_marriages_on_first_partner_id"
    t.index ["second_partner_id"], name: "index_marriages_on_second_partner_id"
  end

  create_table "residence_addresses", force: :cascade do |t|
    t.bigint "family_member_id", null: false
    t.string "address", limit: 250
    t.string "period", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_member_id"], name: "index_residence_addresses_on_family_member_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.text "content"
    t.string "date_type"
    t.date "story_date"
    t.integer "story_year"
    t.boolean "is_date_approx", default: false, null: false
    t.bigint "family_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_stories_on_family_id"
  end

  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_attributes", "family_members"
  add_foreign_key "educations", "family_members"
  add_foreign_key "employments", "family_members"
  add_foreign_key "families", "accounts"
  add_foreign_key "family_members", "families"
  add_foreign_key "family_members", "family_members", column: "father_id"
  add_foreign_key "family_members", "family_members", column: "mother_id"
  add_foreign_key "marriages", "family_members", column: "first_partner_id"
  add_foreign_key "marriages", "family_members", column: "second_partner_id"
  add_foreign_key "residence_addresses", "family_members"
  add_foreign_key "stories", "families"
end
