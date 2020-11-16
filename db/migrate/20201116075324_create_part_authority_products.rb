class CreatePartAuthorityProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :part_authority_products do |t|
      t.string :product_line
      t.string :part_number
      t.string :price
      t.string :core_price
      t.integer :qty_on_hand
      t.integer :vendor_qty_on_hand
      t.integer :packs
      t.timestamps
    end
  end
end
