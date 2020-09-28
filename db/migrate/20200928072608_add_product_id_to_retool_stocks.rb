class AddProductIdToRetoolStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_stocks, :product_id, :integer
  end
end
