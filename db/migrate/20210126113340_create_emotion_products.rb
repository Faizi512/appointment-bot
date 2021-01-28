class CreateEmotionProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :emotion_products do |t|
      t.string :title
      t.string :brand
      t.string :sku
      t.integer :qty
      t.string :price
      t.string :href
      t.timestamps
    end
  end
end
