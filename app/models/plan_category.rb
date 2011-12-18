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

  def self.reg_form(year)
    yr(year).nonempty.order(:name)
  end

  def next_category_on_reg_form
    PlanCategory.reg_form(self.year).where("plan_categories.name > ?", self.name).first
  end
end
