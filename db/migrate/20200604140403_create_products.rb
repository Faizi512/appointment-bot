class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :solidus_sku
      t.references :supplier
      t.string :mpn
      t.string :name

      t.timestamps
    end
  end
end
