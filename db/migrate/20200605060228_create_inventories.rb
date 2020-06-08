class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories do |t|
      t.string :solidus_sku
      t.references :supplier
      t.references :product
      t.string :quantity

      t.timestamps
    end
  end
end
