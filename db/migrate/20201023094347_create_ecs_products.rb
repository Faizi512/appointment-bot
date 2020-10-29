class CreateEcsProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :ecs_products do |t|
      t.string :name
      t.string :mfg_number
      t.string :ecs_number
      t.string :brand
      t.string :price
      t.string :availability
      t.string :href
      t.text :details
      t.timestamps
    end
  end
end
