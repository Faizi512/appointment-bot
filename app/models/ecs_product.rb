class EcsProduct < ApplicationRecord
  has_many :ecs_fitments, dependent: :destroy
  # belongs_to :category
end
