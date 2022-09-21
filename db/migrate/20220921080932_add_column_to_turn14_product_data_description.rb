class AddColumnToTurn14ProductDataDescription < ActiveRecord::Migration[5.1]
  def change
    add_reference :turn14_product_data_descriptions, :supplier, foreign_key: true
    add_reference :turn14_product_data_files, :supplier, foreign_key: true
  end
end
