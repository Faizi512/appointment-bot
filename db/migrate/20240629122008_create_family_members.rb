class CreateFamilyMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :family_members do |t|
      t.string :name
      t.string :relationship
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
