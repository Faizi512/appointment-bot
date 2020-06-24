class Store < ApplicationRecord
	has_many :archive_products, dependent: :destroy
	has_many :latest_products, dependent: :destroy
end
