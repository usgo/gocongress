class PlanCategory < ActiveRecord::Base
  include YearlyModel
  has_many :plans
  validates_presence_of :name
  validates :description, :length => {maximum: 200}

  def self.prefixed_column_list
    all_columns = %w[id created_at description name updated_at year]
    return all_columns.map{|c| "plan_categories.#{c}"}.join(",")
  end

  def self.nonempty
    # postgres 8.3 seems to require that the select clause match the group
    # clause.  this is unfortunate, because now i have to enumerate the
    # columns and if they ever change i have to update prefixed_column_list().
    # in local development on postgres 9.1 i can select * and group by id
    # with no problem.
    return joins(:plans) \
      .select(prefixed_column_list)
      .group(prefixed_column_list) \
      .having("count(*) > 0")
  end

  def self.reg_form(year)
    yr(year).nonempty.order(:name)
  end

  def next_category_on_reg_form
    PlanCategory.reg_form(self.year).where("plan_categories.name > ?", self.name).first
  end
end
