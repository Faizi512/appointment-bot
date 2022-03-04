class LatestProduct < ApplicationRecord
	belongs_to :store
	has_many :archive_products
	has_many :uro_tuning_fitments
end
