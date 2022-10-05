class CreateMilltekcorpKits < ActiveRecord::Migration[5.1]
  def change
    create_table :milltekcorp_kits do |t|
      #t.references :milltekcorp_products, foreign_key: true
      t.string :kit_name
      t.integer :primary_stock
      t.integer :secondary_stock
      t.string :kit_part_number
      t.string :price_MAP
      t.string :dealer_cost 
      t.string :href
      t.string :brand
      t.string :model

      t.timestamps
    end
  end
end
