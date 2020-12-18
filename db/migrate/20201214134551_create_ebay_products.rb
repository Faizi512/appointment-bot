class CreateEbayProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :ebay_products do |t|
      t.string :title
      t.string :sku
      t.string :price
      t.integer :qty
      t.string :href
      t.timestamps
    end
  end
end
