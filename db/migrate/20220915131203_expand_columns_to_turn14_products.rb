class ExpandColumnsToTurn14Products < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :part_description, :string
    add_column :turn14_products, :category, :string
    add_column :turn14_products, :subcategory, :string
    add_column :turn14_products, :dimensions, :string
    add_column :turn14_products, :carb_eo_number, :string
    add_column :turn14_products, :clearence_item, :boolean
    add_column :turn14_products, :units_per_sku, :integer
    add_column :turn14_products, :price_list, :string
  end
end
