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

ActiveRecord::Schema[8.1].define(version: 2026_11_26_070400) do
  create_table "projects", force: :cascade do |t|
    t.integer "tutor_id"
    t.string "title", limit: 150, null: false
    t.string "title_key", limit: 150, null: false
    t.text "summary", null: false
    t.integer "status", default: 0, null: false
    t.bigint "budget", null: false
    t.date "starts_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_projects_on_status"
    t.index ["title_key"], name: "index_projects_on_title_key", unique: true
    t.index ["tutor_id"], name: "index_projects_on_tutor_id"
    t.check_constraint "budget > 0", name: "projects_budget_positive"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "name", limit: 150, null: false
    t.integer "kind", null: false
    t.string "nit", limit: 11, null: false
    t.string "phone", limit: 10, null: false
    t.string "email", limit: 160, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nit"], name: "index_sponsors_on_nit", unique: true
  end

  create_table "sponsorships", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "sponsor_id", null: false
    t.bigint "amount", null: false
    t.date "committed_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "sponsor_id"], name: "index_sponsorships_on_project_id_and_sponsor_id", unique: true
    t.index ["project_id"], name: "index_sponsorships_on_project_id"
    t.index ["sponsor_id"], name: "index_sponsorships_on_sponsor_id"
    t.check_constraint "amount > 0", name: "sponsorships_amount_positive"
  end

  create_table "student_leads", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", limit: 120, null: false
    t.string "program", limit: 120, null: false
    t.integer "semester", null: false
    t.string "email", limit: 160, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_student_leads_on_project_id", unique: true
    t.check_constraint "semester BETWEEN 1 AND 12", name: "student_leads_semester_range"
  end

  create_table "tutors", force: :cascade do |t|
    t.string "name", limit: 120, null: false
    t.string "faculty", limit: 120, null: false
    t.string "email", limit: 160, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_tutors_on_email", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "projects", "tutors"
  add_foreign_key "sessions", "users"
  add_foreign_key "sponsorships", "projects"
  add_foreign_key "sponsorships", "sponsors"
  add_foreign_key "student_leads", "projects"
end
