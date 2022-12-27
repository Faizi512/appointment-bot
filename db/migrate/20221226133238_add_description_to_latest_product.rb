class AddDescriptionToLatestProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :latest_products, :description, :text
  end
end
