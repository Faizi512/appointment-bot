class CreateFitments < ActiveRecord::Migration[5.1]
  def change
    create_table :fitments do |t|
      t.text :fitment_model
      t.references :fcp_product, foreign_key: true
      t.integer :kit_id, foreign_key: true
    end
  end
end
