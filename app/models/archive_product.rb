class ArchiveProduct < ApplicationRecord
	belongs_to :store
	belongs_to :latest_product
end
