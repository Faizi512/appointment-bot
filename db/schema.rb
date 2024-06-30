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

ActiveRecord::Schema.define(version: 20240629122008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

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
    t.text "description"
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

  create_table "cspracinglogs", force: :cascade do |t|
    t.string "offset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "appointment_type"
    t.boolean "is_family"
    t.integer "family_id"
    t.integer "number_of_appointments"
    t.string "centre_city"
    t.string "appointment_category"
    t.string "phone_number"
    t.string "verification_code"
    t.date "appointment_date"
    t.time "appointment_time"
    t.string "visa_type"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "customer_phone_number"
    t.string "nationality"
    t.string "passport_type"
    t.string "passport_number"
    t.date "passport_issue_date"
    t.date "passport_expiry_date"
    t.string "passport_issue_place"
    t.boolean "is_sms"
    t.boolean "is_prime_time_service"
    t.boolean "is_form_filling"
    t.boolean "is_photocopy_b_w"
    t.boolean "is_photograph"
    t.boolean "is_premium_lounge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.boolean "is_appointment_booked"
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

  create_table "family_members", force: :cascade do |t|
    t.string "name"
    t.string "relationship"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_family_members_on_customer_id"
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
    t.string "qty"
    t.index ["category_id"], name: "index_fcp_products_on_category_id"
  end

  create_table "fitments", force: :cascade do |t|
    t.text "fitment_model"
    t.bigint "fcp_product_id"
    t.integer "kit_id"
    t.index ["fcp_product_id"], name: "index_fitments_on_fcp_product_id"
  end

  create_table "holley_performance_available_promises", force: :cascade do |t|
    t.string "mpn"
    t.string "brand"
    t.string "atp_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "keystone_products", force: :cascade do |t|
    t.string "vendor_name"
    t.string "vcpn"
    t.string "vendor_code"
    t.string "part_number"
    t.string "manufacturer_part_no"
    t.string "long_description"
    t.string "jobber_price"
    t.string "cost"
    t.string "ups_able"
    t.string "core_charge"
    t.integer "case_qty"
    t.string "is_non_returnable"
    t.string "upc_code"
    t.integer "total_qty"
    t.string "kit_components"
    t.string "is_kit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "last_visited_pages", force: :cascade do |t|
    t.string "section"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "description"
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

  create_table "ma_performance_details", force: :cascade do |t|
    t.string "variant_id"
    t.text "description"
    t.text "features"
    t.text "benefits"
    t.text "included"
    t.string "variant_href"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "stock"
    t.string "esd"
    t.bigint "turn14_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turn14_product_id"], name: "index_manufacturers_on_turn14_product_id"
  end

  create_table "maperformancelogs", force: :cascade do |t|
    t.string "offset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "milltekcorp_kits", force: :cascade do |t|
    t.string "kit_name"
    t.integer "primary_stock"
    t.integer "secondary_stock"
    t.string "kit_part_number"
    t.string "price_MAP"
    t.string "dealer_cost"
    t.string "href"
    t.string "brand"
    t.string "model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "milltekcorp_products", force: :cascade do |t|
    t.bigint "milltekcorp_kit_id"
    t.integer "us_local_stock"
    t.integer "uk_remote_stock"
    t.string "product_part_number"
    t.string "product_description"
    t.string "product_price_MAP"
    t.string "product_dealer_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["milltekcorp_kit_id"], name: "index_milltekcorp_products_on_milltekcorp_kit_id"
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
    t.string "brand"
    t.boolean "present_in_file"
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

  create_table "thmotorsports_products", force: :cascade do |t|
    t.string "mpn"
    t.string "current_price"
    t.string "product_title"
    t.string "manufacturer"
    t.string "product_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thmotorsports_products_fitments", force: :cascade do |t|
    t.string "mpn"
    t.string "fitment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "thmotorsports_product_id"
  end

  create_table "throtlurllogs", force: :cascade do |t|
    t.string "offset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turn14_available_promises", force: :cascade do |t|
    t.string "mpn"
    t.string "location"
    t.string "quantity"
    t.string "est_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "turn14_product_data", force: :cascade do |t|
    t.bigint "supplier_id"
    t.string "item_id"
    t.index ["supplier_id"], name: "index_turn14_product_data_on_supplier_id"
  end

  create_table "turn14_product_data_descriptions", force: :cascade do |t|
    t.string "product_id"
    t.string "desc_type"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id"
    t.index ["supplier_id"], name: "index_turn14_product_data_descriptions_on_supplier_id"
  end

  create_table "turn14_product_data_files", force: :cascade do |t|
    t.string "product_id"
    t.string "file_type"
    t.string "file_extension"
    t.string "media_content"
    t.boolean "generic"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id"
    t.index ["supplier_id"], name: "index_turn14_product_data_files_on_supplier_id"
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
    t.string "brand"
    t.string "active"
    t.string "regular_stock"
    t.string "not_carb_approved"
    t.string "barcode"
    t.string "alternate_part_number"
    t.string "prop_65"
    t.string "epa"
    t.string "part_description"
    t.string "category"
    t.string "subcategory"
    t.string "dimensions"
    t.string "carb_eo_number"
    t.boolean "clearence_item"
    t.integer "units_per_sku"
    t.string "price_list"
    t.string "thumbnail"
    t.float "map_price"
    t.float "price_price"
    t.float "retail_price"
    t.float "jobber_price"
    t.float "purchase_cost"
    t.integer "dim_box_number"
    t.float "dim_length"
    t.float "dim_width"
    t.float "dim_height"
    t.float "dim_weight"
    t.index ["item_id"], name: "index_turn14_products_on_item_id"
    t.index ["supplier_id"], name: "index_turn14_products_on_supplier_id"
  end

  create_table "turn14_tokens", force: :cascade do |t|
    t.json "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uro_tuning_fitments", force: :cascade do |t|
    t.string "mpn"
    t.string "fitment"
    t.bigint "latest_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_id"
    t.index ["latest_product_id"], name: "index_uro_tuning_fitments_on_latest_product_id"
  end

  create_table "urotuning_ftiments_page_logs", force: :cascade do |t|
    t.string "offset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "archived_purchase_orders", "turn14_products"
  add_foreign_key "categories", "sections"
  add_foreign_key "ecs_fitments", "ecs_products"
  add_foreign_key "ecs_taxons", "ecs_products"
  add_foreign_key "family_members", "customers"
  add_foreign_key "fcp_products", "categories"
  add_foreign_key "fitments", "fcp_products"
  add_foreign_key "latest_purchase_orders", "turn14_products"
  add_foreign_key "manufacturers", "turn14_products"
  add_foreign_key "milltekcorp_products", "milltekcorp_kits"
  add_foreign_key "turn14_product_data_descriptions", "suppliers"
  add_foreign_key "turn14_product_data_files", "suppliers"
  add_foreign_key "uro_tuning_fitments", "latest_products"
end
