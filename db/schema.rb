# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090908181146) do

  create_table "bootcamps", :force => true do |t|
    t.string   "city"
    t.string   "message"
    t.string   "date"
    t.string   "time"
    t.string   "button_id"
    t.decimal  "price"
    t.integer  "max_students"
    t.boolean  "space_available"
    t.boolean  "registration_open"
    t.string   "timepoint"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.string   "tx_token"
    t.decimal  "amount"
    t.integer  "bootcamp_id"
    t.integer  "student_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :force => true do |t|
    t.integer  "bootcamp_id"
    t.string   "tx_token"
    t.boolean  "tx_accepted"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
