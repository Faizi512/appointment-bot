class Section < ApplicationRecord
    has_many :categories, dependent: :destroy
end
