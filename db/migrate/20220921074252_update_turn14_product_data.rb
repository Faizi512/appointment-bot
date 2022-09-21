class UpdateTurn14ProductData < ActiveRecord::Migration[5.1]
  def change
    rename_column :turn14_product_data, :description, :market_description
    add_column :turn14_product_data, :product_description, :string
  end
end
