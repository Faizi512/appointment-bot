class CreatePartAuthorityBrandsMpns < ActiveRecord::Migration[5.1]
  def change
    create_table :part_authority_brands_mpns do |t|
      t.string :brand
      t.string :mpn
      t.string :sku
      t.string :product_name

      t.timestamps
    end
    add_index :part_authority_brands_mpns, :mpn
    add_index :part_authority_brands_mpns, :brand
  end
end
