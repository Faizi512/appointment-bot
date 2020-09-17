class FcpProductKit < ApplicationRecord
    belongs_to :fcp_product, :foreign_key => "fcp_product_id"
    belongs_to :kit, :foreign_key => "kit_id"
end