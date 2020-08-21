class CreateRetoolStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :retool_stocks do |t|
      t.integer :variant_id
      t.string :variant_name
      t.string :variant_sku
      t.string :variant_mpn
      t.string :product_name
      t.datetime :product_available_on
      t.string :stock_location_name
      t.string :brand_name
      t.integer :count_on_hand
      t.integer :t14_inventory
    end
  end
end
