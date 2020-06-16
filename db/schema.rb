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

ActiveRecord::Schema.define(version: 20200616110204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "inventories", force: :cascade do |t|
    t.string "solidus_sku"
    t.bigint "supplier_id"
    t.bigint "product_id"
    t.string "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["supplier_id"], name: "index_inventories_on_supplier_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "solidus_sku"
    t.bigint "supplier_id"
    t.string "mpn"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "supplier_id"
    t.string "name"
    t.string "solidus_sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_suppliers_on_supplier_id"
  end

  create_table "turn14_open_orders", force: :cascade do |t|
    t.bigint "supplier_id"
    t.string "date"
    t.string "purchase_order"
    t.string "sales_order"
    t.string "part_number"
    t.string "quantity"
    t.string "open_qty"
    t.text "eta_information"
    t.string "warehouse"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_turn14_open_orders_on_supplier_id"
  end

  create_table "turn14_products", force: :cascade do |t|
    t.bigint "supplier_id"
    t.string "item_id"
    t.string "name"
    t.string "part_number"
    t.string "mfr_part_number"
    t.string "brand_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_turn14_products_on_supplier_id"
  end

end
