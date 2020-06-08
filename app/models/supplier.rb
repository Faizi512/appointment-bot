class Supplier < ApplicationRecord
	has_many :products, dependent: :destroy
	has_many :inventories, dependent: :destroy
end
