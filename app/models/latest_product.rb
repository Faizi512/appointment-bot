class LatestProduct < ApplicationRecord
	belongs_to :store
	has_many :archive_products
end
