class AddColumnToLatestProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :latest_products, :price, :string
    add_column :latest_products, :product_title, :string
  end
end
