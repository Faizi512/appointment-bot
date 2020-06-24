class CreateArchiveProducts < ActiveRecord::Migration[5.1]
  def change

      create_table :archive_products do |t|
        t.string :brand
        t.string :mpn
        t.string :sku
        t.integer :inventory_quantity
        t.string :slug
        t.string :variant_id
        t.string :product_id
        t.string :href
        t.references :store
        t.references :latest_product
      
        t.timestamps
        end
  end
end
