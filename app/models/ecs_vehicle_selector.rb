class EcsVehicleSelector < ApplicationRecord
  def print_data
    "Vehicle:#{vehicle} Series:#{series} Chassis:#{chassis} Engine:#{engine} Drivetrain:#{drivetrain} Model:#{model} Generation:#{generation} Config:#{config}"
  end
end
