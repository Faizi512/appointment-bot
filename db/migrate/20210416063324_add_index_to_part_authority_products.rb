class AddIndexToPartAuthorityProducts < ActiveRecord::Migration[5.1]
  def change
    add_index :part_authority_products, :part_number
    add_index :part_authority_products, :product_line
  end
end
