class EventCategory < ActiveRecord::Base
  include YearlyModel
  has_many :events
  validates :name, :presence => true, :length => { maximum: 25 }
end
