class Fitment < ApplicationRecord
  belongs_to :fcp_product, optional: true
  belongs_to :kit, optional: true
end
