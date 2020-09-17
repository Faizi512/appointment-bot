class FcpProduct < ApplicationRecord
    belongs_to :category
    has_many :fcp_product_kits
    has_many :kits, :through => :fcp_product_kits
end
