class Supplier < ApplicationRecord
	has_many :products, dependent: :destroy
	has_many :turn14_products, dependent: :destroy
	has_many :turn14_open_orders, dependent: :destroy
	has_many :inventories, dependent: :destroy
end
