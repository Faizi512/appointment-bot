class CreateTurn14Products < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_products do |t|
      t.references :supplier
      t.string :item_id
      t.string :name
      t.string :part_number
      t.string :mfr_part_number
      t.string :brand_id

      t.timestamps
    end
  end
end
