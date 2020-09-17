class CreateVehicleSelector < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicle_selectors do |t|
      t.integer :year
      t.string :make
      t.string :base_vehicle
      t.string :vehicle
      t.string :body_style_config
      t.string :engine_config
      t.string :transmission

      t.timestamps
    end
  end
end
