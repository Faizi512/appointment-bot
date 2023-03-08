class AddColumnPresentInFileToPartAuthorityProduct < ActiveRecord::Migration[5.1]
  def up
    add_column :part_authority_products, :present_in_file, :boolean
  end
  def down
    remove_column :part_authority_products, :presentInFile, :boolean
  end
end
