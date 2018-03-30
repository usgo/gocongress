class Event < ApplicationRecord
  include YearlyModel
  has_many :plan_categories
  validates :name, :presence => true
  scope :alphabetical, -> { order(:name) }
end
