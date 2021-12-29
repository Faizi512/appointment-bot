class AddColumnToThProductsFitments < ActiveRecord::Migration[5.1]
  def change
    add_column :thmotorsports_products_fitments, :thmotorsports_product_id, :string
  end
end
