class CreateTurn14OpenOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_open_orders do |t|
      t.references :supplier
      t.string :date
      t.string :purchase_order
      t.string :sales_order
      t.string :part_number
      t.string :quantity
      t.string :open_qty
      t.text :eta_information
      t.string :warehouse

      t.timestamps
    end
  end
end
