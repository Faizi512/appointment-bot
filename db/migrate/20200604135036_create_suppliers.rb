class CreateSuppliers < ActiveRecord::Migration[5.1]
  def change
    create_table :suppliers do |t|
      t.string :supplier_id
      t.string :name
      t.string :solidus_sku, null: false

      t.timestamps
    end
    add_index :suppliers, :supplier_id
  end
end
