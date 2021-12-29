class CreateThmotorsportsProductsFitments < ActiveRecord::Migration[5.1]
  def change
    create_table :thmotorsports_products_fitments do |t|
      t.string :mpn
      t.string :fitment

      t.timestamps
    end
  end
end
