class Event < ActiveRecord::Base
  has_many :plan_categories
  validates :name, :presence => true
end
