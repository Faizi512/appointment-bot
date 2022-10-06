class MilltekcorpKit < ApplicationRecord
    has_many :milltekcorp_products, dependent: :destroy
end
