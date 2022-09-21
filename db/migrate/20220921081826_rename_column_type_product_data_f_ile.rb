class RenameColumnTypeProductDataFIle < ActiveRecord::Migration[5.1]
  def change
    rename_column :turn14_product_data_files, :type, :file_type
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
