class CreateEcsTaxons < ActiveRecord::Migration[5.1]
  def change
    create_table :ecs_taxons do |t|
      t.string :taxon
      t.string :sub_taxon
      t.references :ecs_product, foreign_key: true
      t.timestamps
    end
  end
end
