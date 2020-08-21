class AddIndexToRetoolStocks < ActiveRecord::Migration[5.1]
  def change
  	add_index :retool_stocks, :variant_id
  	add_index :retool_stocks, :variant_sku
  end
end
