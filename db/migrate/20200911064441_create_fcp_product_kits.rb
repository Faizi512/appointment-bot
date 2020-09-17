class CreateFcpProductKits < ActiveRecord::Migration[5.1]
  def change
    create_table :fcp_product_kits do |t|
        t.integer :fcp_product_id
        t.integer :kit_id
    end
  end
end
