class CreateRetoolOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :retool_orders do |t|
      t.integer :order_id
      t.date :eta_date
      t.date :contracted_date
    end
  end
end
