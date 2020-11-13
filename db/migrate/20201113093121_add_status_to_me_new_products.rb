class AddStatusToMeNewProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :me_new_products, :status, :string
  end
end
