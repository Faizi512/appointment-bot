class AddItemIdToRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_orders, :item_id, :integer
  end
end
