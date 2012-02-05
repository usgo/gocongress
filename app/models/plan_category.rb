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

  def self.reg_form(year, age)
    yr(year)
      .nonempty
      .where("(age_min is null or age_min <= ?) and (age_max is null or age_max >= ?)", age, age)
      .order(:name)
  end

  # `first_reg_form_category` returns nil if there are no appropriate categories
  def self.first_reg_form_category(year, attendee)
    reg_form(year, attendee.age_in_years).first
  end

  # Instance methods

  def next_reg_form_category(attendee)
    PlanCategory.reg_form(self.year, attendee.age_in_years) \
      .where("plan_categories.name > ?", self.name) \
      .first
  end
end
