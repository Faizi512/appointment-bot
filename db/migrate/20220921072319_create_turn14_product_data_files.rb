class CreateTurn14ProductDataFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_product_data_files do |t|
      t.string :product_id
      t.string :type
      t.string :file_extension
      t.string :media_content
      t.boolean :generic
      t.string :url

      t.timestamps
    end
  end
end
