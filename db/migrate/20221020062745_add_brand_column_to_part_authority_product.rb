class AddBrandColumnToPartAuthorityProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :part_authority_products, :brand, :string
  end
end
