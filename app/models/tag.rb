class Tag < ApplicationRecord
  has_many :charity_tags
  has_many :charities, through: :charity_tags
  validates :name, presence: true
end
