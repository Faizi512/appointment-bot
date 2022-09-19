class AddPriceDataToTurn14Product < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :map_price, :float
    add_column :turn14_products, :price_price, :float
    add_column :turn14_products, :retail_price, :float
    add_column :turn14_products, :jobber_price, :float
  end
end
