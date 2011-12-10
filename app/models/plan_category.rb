class PlanCategory < ActiveRecord::Base
  include YearlyModel
  has_many :plans
  validates_presence_of :name
end
