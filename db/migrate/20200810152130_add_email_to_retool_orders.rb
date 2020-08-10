class AddEmailToRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_orders, :email, :string
  end
end
