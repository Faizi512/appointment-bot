class CreateHolleyPerformanceAvailablePromises < ActiveRecord::Migration[5.1]
  def change
    create_table :holley_performance_available_promises do |t|
      t.string :mpn
      t.string :brand
      t.string :atp_date

      t.timestamps
    end
  end
end
