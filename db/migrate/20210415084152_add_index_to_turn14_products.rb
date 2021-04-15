class AddIndexToTurn14Products < ActiveRecord::Migration[5.1]
  def change
    add_index :turn14_products, :item_id
  end
end
