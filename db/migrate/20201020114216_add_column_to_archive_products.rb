class AddColumnToArchiveProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :archive_products, :price, :string
    add_column :archive_products, :product_title, :string
  end
end
