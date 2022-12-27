class AddDescriptionToArchiveProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :archive_products, :description, :text
  end
end
