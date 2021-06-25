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

ActiveRecord::Schema.define(version: 20210416063324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "archive_products", force: :cascade do |t|
    t.string "brand"
    t.string "mpn"
    t.string "sku"
    t.integer "inventory_quantity"
    t.string "slug"
    t.string "variant_id"
    t.string "product_id"
    t.string "href"
    t.bigint "store_id"
    t.bigint "latest_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "price"
    t.string "product_title"
    t.index ["latest_product_id"], name: "index_archive_products_on_latest_product_id"
    t.index ["store_id"], name: "index_archive_products_on_store_id"
  end

  create_table "archived_purchase_orders", force: :cascade do |t|
    t.string "location"
    t.integer "qty_on_order"
    t.string "estimated_availability"
    t.bigint "turn14_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turn14_product_id"], name: "index_archived_purchase_orders_on_turn14_product_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.bigint "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_categories_on_section_id"
  end

  create_table "ebay_products", force: :cascade do |t|
    t.string "title"
    t.string "sku"
    t.string "price"
    t.integer "qty"
    t.string "href"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ecs_fitments", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.string "sub_model"
    t.string "engine"
    t.bigint "ecs_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ecs_product_id"], name: "index_ecs_fitments_on_ecs_product_id"
  end

  create_table "ecs_products", force: :cascade do |t|
    t.string "name"
    t.string "mfg_number"
    t.string "ecs_number"
    t.string "brand"
    t.string "price"
    t.string "availability"
    t.string "href"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ecs_taxons", force: :cascade do |t|
    t.string "taxon"
    t.string "sub_taxon"
    t.bigint "ecs_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ecs_product_id"], name: "index_ecs_taxons_on_ecs_product_id"
  end

  create_table "ecs_vehicle_selectors", force: :cascade do |t|
    t.string "vehicle"
    t.string "series"
    t.string "chassis"
    t.string "engine"
    t.string "drivetrain"
    t.string "model"
    t.string "generation"
    t.string "config"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emotion_products", force: :cascade do |t|
    t.string "title"
    t.string "brand"
    t.string "sku"
    t.integer "qty"
    t.string "price"
    t.string "href"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fcp_product_kits", force: :cascade do |t|
    t.integer "fcp_product_id"
    t.integer "kit_id"
  end

  create_table "fcp_products", force: :cascade do |t|
    t.string "title"
    t.string "brand"
    t.string "sku"
    t.string "price"
    t.string "available_at"
    t.string "fcp_euro_id"
    t.string "quality"
    t.text "oe_numbers"
    t.text "mfg_numbers"
    t.string "href"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_fcp_products_on_category_id"
  end

  create_table "fitments", force: :cascade do |t|
    t.text "fitment_model"
    t.bigint "fcp_product_id"
    t.integer "kit_id"
    t.index ["fcp_product_id"], name: "index_fitments_on_fcp_product_id"
  end

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

  create_table "latest_products", force: :cascade do |t|
    t.string "brand"
    t.string "mpn"
    t.string "sku"
    t.integer "inventory_quantity"
    t.string "slug"
    t.string "variant_id"
    t.string "product_id"
    t.string "href"
    t.bigint "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "price"
    t.string "product_title"
    t.index ["store_id"], name: "index_latest_products_on_store_id"
  end

  create_table "latest_purchase_orders", force: :cascade do |t|
    t.string "location"
    t.integer "qty_on_order"
    t.string "estimated_availability"
    t.bigint "turn14_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turn14_product_id"], name: "index_latest_purchase_orders_on_turn14_product_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "stock"
    t.string "esd"
    t.bigint "turn14_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turn14_product_id"], name: "index_manufacturers_on_turn14_product_id"
  end

  create_table "me_categories", id: false, force: :cascade do |t|
    t.integer "modded_catid"
    t.string "modded_catname", limit: 255
    t.integer "fcp_catid"
    t.string "fcp_catname", limit: 255
  end

  create_table "me_fcp_brands", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "fcp_brand_name", limit: 255
    t.string "modded_brand_name", limit: 255
    t.integer "modded_brand_id"
  end

  create_table "me_inventory_db", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "brand", limit: 255
    t.string "product_name", limit: 255
    t.string "mpn", limit: 255
    t.string "sku", limit: 255
    t.decimal "cost", precision: 10, scale: 2
    t.integer "qty"
    t.string "loc", limit: 255
    t.string "stock_state", limit: 255
  end

  create_table "me_new_products", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "brand", limit: 255
    t.integer "brand_id"
    t.text "product_name"
    t.text "slug"
    t.string "sku", limit: 255
    t.string "price", limit: 255
    t.integer "cost"
    t.string "retail", limit: 255
    t.string "mpn", limit: 255
    t.text "taxon_ids"
    t.text "taxon_name"
    t.string "fcpeuro_id", limit: 255
    t.string "fcpeuro_productsid", limit: 255
    t.string "fcpeuro_quality", limit: 255
    t.text "fcpeuro_oenumbers"
    t.text "fcpeuro_mfgnumbers"
    t.string "status"
  end

  create_table "me_purchase_orders", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "modded_po", limit: 255
    t.string "vendor", limit: 255
    t.string "brand", limit: 255
    t.string "mpn", limit: 255
    t.integer "qty"
    t.string "sku", limit: 255
    t.string "stock_state", limit: 255
    t.string "tracking", limit: 255
    t.string "product_name", limit: 255
  end

  create_table "new_product_db", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "product_name", limit: 255
    t.integer "sku"
    t.string "brand", limit: 255
    t.integer "price"
    t.integer "cost_price"
    t.integer "retail_price"
    t.string "mpn", limit: 255
    t.text "description"
    t.text "image"
    t.text "features"
    t.text "warranty"
    t.text "installation"
    t.text "notes"
  end

  create_table "part_authority_brands", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('parts_authority_brands_id_seq'::regclass)" }, null: false
    t.integer "brand_id"
    t.string "brand_name", limit: 255
    t.string "product_line", limit: 255
  end

  create_table "part_authority_brands_mpns", force: :cascade do |t|
    t.string "brand"
    t.string "mpn"
    t.string "sku"
    t.string "product_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand"], name: "index_part_authority_brands_mpns_on_brand"
    t.index ["mpn"], name: "index_part_authority_brands_mpns_on_mpn"
  end

  create_table "part_authority_products", force: :cascade do |t|
    t.string "product_line"
    t.string "part_number"
    t.string "price"
    t.string "core_price"
    t.integer "qty_on_hand"
    t.integer "vendor_qty_on_hand"
    t.integer "packs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["part_number"], name: "index_part_authority_products_on_part_number"
    t.index ["product_line"], name: "index_part_authority_products_on_product_line"
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

  create_table "retool_orders", force: :cascade do |t|
    t.integer "order_id"
    t.datetime "eta_date"
    t.datetime "contracted_date"
    t.string "order_number"
    t.string "shipment_number"
    t.text "product_name"
    t.string "order_state"
    t.string "shipment_state"
    t.string "payment_state"
    t.datetime "completed_at"
    t.integer "store_location_id"
    t.string "email"
    t.string "stock_location_name"
    t.integer "item_id"
    t.string "product_eta"
  end

  create_table "retool_stocks", force: :cascade do |t|
    t.integer "variant_id"
    t.string "variant_name"
    t.string "variant_sku"
    t.string "variant_mpn"
    t.string "product_name"
    t.datetime "product_available_on"
    t.string "stock_location_name"
    t.string "brand_name"
    t.integer "count_on_hand"
    t.integer "t14_inventory"
    t.integer "product_id"
    t.string "mfr_stock"
    t.string "mfr_esd"
    t.index ["variant_id"], name: "index_retool_stocks_on_variant_id"
    t.index ["variant_sku"], name: "index_retool_stocks_on_variant_sku"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.string "section_id"
    t.string "href"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.string "href"
    t.string "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.float "price"
    t.index ["item_id"], name: "index_turn14_products_on_item_id"
    t.index ["supplier_id"], name: "index_turn14_products_on_supplier_id"
  end

  create_table "vehicle_selectors", force: :cascade do |t|
    t.integer "year"
    t.string "make"
    t.string "base_vehicle"
    t.string "vehicle"
    t.string "body_style_config"
    t.string "engine_config"
    t.string "transmission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wufoo_rma", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "order_id", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "email", limit: 255
    t.string "reason_contact", limit: 255
    t.string "reason_return", limit: 255
    t.string "have_installed", limit: 255
    t.string "year", limit: 255
    t.string "make", limit: 255
    t.string "model", limit: 255
    t.text "cancel_exp"
    t.text "return_exp"
    t.datetime "submitted_at"
  end

  add_foreign_key "archived_purchase_orders", "turn14_products"
  add_foreign_key "categories", "sections"
  add_foreign_key "ecs_fitments", "ecs_products"
  add_foreign_key "ecs_taxons", "ecs_products"
  add_foreign_key "fcp_products", "categories"
  add_foreign_key "fitments", "fcp_products"
  add_foreign_key "latest_purchase_orders", "turn14_products"
  add_foreign_key "manufacturers", "turn14_products"
end
