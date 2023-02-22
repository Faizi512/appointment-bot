class AddColumnToFcpProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :fcp_products, :qty, :string
  end
end
