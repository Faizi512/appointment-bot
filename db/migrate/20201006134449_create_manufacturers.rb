class CreateManufacturers < ActiveRecord::Migration[5.1]
  def change
    create_table :manufacturers do |t|
      t.string :stock
      t.string :esd
      t.references :turn14_product, foreign_key: true
      t.timestamps
    end
  end
end
