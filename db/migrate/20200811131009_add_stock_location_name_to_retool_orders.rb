class AddStockLocationNameToRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_orders, :stock_location_name, :string
  end
end
