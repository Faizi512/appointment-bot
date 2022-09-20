class CreateTurn14ProductData < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_product_data do |t|
      t.references :supplier
      t.string :item_id
      t.string :description
      t.string :image
      t.string :manuals
    end
  end
end
