class CreateUroTuningFitments < ActiveRecord::Migration[5.1]
  def change
    create_table :uro_tuning_fitments do |t|
      t.string :mpn
      t.string :fitment
      t.references :latest_product, foreign_key: true
      t.timestamps
    end
  end
end
