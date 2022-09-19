class AddPurchaseCostToTurn14Product < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :purchase_cost, :float
  end
end
