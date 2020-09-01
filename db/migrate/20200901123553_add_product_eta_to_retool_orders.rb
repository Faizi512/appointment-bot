class AddProductEtaToRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_orders, :product_eta, :string
  end
end
