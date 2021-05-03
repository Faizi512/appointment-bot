class AddPriceToTurn14Product < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :price, :float
  end
end
