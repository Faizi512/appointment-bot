class AddThumbnailToTurn14Product < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :thumbnail, :string
  end
end
