class Kit < ApplicationRecord
    self.table_name = "fcp_products"
    
    belongs_to :category
    has_many :fcp_product_kits, dependent: :destroy
    has_many :fcp_products, :through => :fcp_product_kits
    has_many :fitments, dependent: :destroy
end