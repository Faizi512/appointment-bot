class CreateThmotorsportsProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :thmotorsports_products do |t|
      t.string :mpn
      t.string :current_price
      t.string :product_title
      t.string :manufacturer
      t.string :product_details

      t.timestamps
    end
  end
end
