class T14AddColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :brand, :string
    add_column :turn14_products, :active, :string
    add_column :turn14_products, :regular_stock, :string
    add_column :turn14_products, :not_carb_approved, :string
    add_column :turn14_products, :barcode, :string
    add_column :turn14_products, :alternate_part_number, :string
    add_column :turn14_products, :prop_65, :string
    add_column :turn14_products, :epa, :string
  end
end
