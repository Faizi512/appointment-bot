class CreateTurn14ProductDataDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_product_data_descriptions do |t|
      t.string :product_id
      t.string :type
      t.string :description
      t.timestamps
    end
  end
end
