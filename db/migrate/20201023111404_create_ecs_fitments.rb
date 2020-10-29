class CreateEcsFitments < ActiveRecord::Migration[5.1]
  def change
    create_table :ecs_fitments do |t|
      t.string :make
      t.string :model
      t.string :sub_model
      t.string :engine
      t.references :ecs_product, foreign_key: true
      t.timestamps
    end
  end
end
