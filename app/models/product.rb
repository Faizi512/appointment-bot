class Product < ApplicationRecord
	belongs_to :supplier
	has_many :inventories, dependent: :destroy
end
