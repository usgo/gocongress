class PlanCategory < ActiveRecord::Base
  include YearlyModel
  has_many :plans
  validates_presence_of :name
  validates :description, :length => {maximum: 200}

  def self.nonempty
    joins(:plans) \
      .group("plan_categories.id") \
      .having("count(*) > 0")
  end
end
