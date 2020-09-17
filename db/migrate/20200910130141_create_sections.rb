class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.string :name
      t.string :section_id
      t.string :href

      t.timestamps
    end
  end
end
