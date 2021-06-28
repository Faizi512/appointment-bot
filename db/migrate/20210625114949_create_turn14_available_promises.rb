class CreateTurn14AvailablePromises < ActiveRecord::Migration[5.1]
  def change
    create_table :turn14_available_promises do |t|
      t.string :mpn
      t.string :location
      t.string :quantity
      t.string :est_date

      t.timestamps
    end
  end
end
