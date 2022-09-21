class RemoveColumnsTurn14ProductData < ActiveRecord::Migration[5.1]
  def change
    remove_column :turn14_product_data, :market_description
    remove_column :turn14_product_data, :product_description
    remove_column :turn14_product_data, :image
    remove_column :turn14_product_data, :manuals
  end
end

