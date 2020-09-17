class Category < ApplicationRecord
  belongs_to :section
  has_many :fcp_products, dependent: :destroy
  has_many :kits, dependent: :destroy
end
