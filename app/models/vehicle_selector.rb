class VehicleSelector < ApplicationRecord
    def self.save(params)
        create(params)
    end
end
