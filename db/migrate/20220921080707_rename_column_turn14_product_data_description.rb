class RenameColumnTurn14ProductDataDescription < ActiveRecord::Migration[5.1]
  def change
    rename_column :turn14_product_data_descriptions, :type, :desc_type
  end
end
