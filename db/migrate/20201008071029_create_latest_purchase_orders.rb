class CreateLatestPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :latest_purchase_orders do |t|
      t.string :location
      t.integer :qty_on_order
      t.string :estimated_availability
      t.references :turn14_product, foreign_key: true
      t.timestamps
    end
  end
end
