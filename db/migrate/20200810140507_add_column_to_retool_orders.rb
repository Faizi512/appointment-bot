class AddColumnToRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_orders, :order_number, :string
    add_column :retool_orders, :shipment_number, :string
    add_column :retool_orders, :product_name, :text
    add_column :retool_orders, :order_state, :string
    add_column :retool_orders, :shipment_state, :string
    add_column :retool_orders, :payment_state, :string
    add_column :retool_orders, :completed_at, :datetime
    add_column :retool_orders, :store_location_id, :integer
  end
end
