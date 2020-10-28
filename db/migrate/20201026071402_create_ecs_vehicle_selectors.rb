class CreateEcsVehicleSelectors < ActiveRecord::Migration[5.1]
  def change
    create_table :ecs_vehicle_selectors do |t|
      t.string :vehicle
      t.string :series
      t.string :chassis
      t.string :engine
      t.string :drivetrain
      t.string :model
      t.string :generation
      t.string :config
      t.timestamps
    end
  end
end
