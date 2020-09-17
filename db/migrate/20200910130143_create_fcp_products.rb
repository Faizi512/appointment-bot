class CreateFcpProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :fcp_products do |t|
      t.string :title
      t.string :brand
      t.string :sku
      t.string :price
      t.string :available_at
      t.string :fcp_euro_id
      t.string :quality
      t.text :oe_numbers
      t.text :mfg_numbers
      t.string :href
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
