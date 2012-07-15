class Event < ActiveRecord::Base
  include YearlyModel
  has_many :plan_categories
  attr_accessible :name
  validates :name, :presence => true
  scope :alphabetical, order(:name)
end
