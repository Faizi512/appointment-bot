class CreateMilltekcorpProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :milltekcorp_products do |t|

      t.references :milltekcorp_kit, foreign_key: true
      
      t.integer :us_local_stock
      t.integer :uk_remote_stock
      t.string :product_part_number
      t.string :product_description
      t.string :product_price_MAP
      t.string :product_dealer_cost
      
      t.timestamps
    end
  end
end
