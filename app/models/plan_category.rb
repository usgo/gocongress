class PlanCategory < ActiveRecord::Base
  include YearlyModel

  belongs_to :event
  has_many :plans

  validates :event, :presence => true
  validates :name, :presence => true,
    :uniqueness => {
      :scope => :year,
      :case_sensitive => false,
      :message => "with that name already exists"
    }
  validates :description, :length => {maximum: 200}

  scope :alphabetical, order(:name)

  # Class methods
  # ----------------

  def self.columns_with_table_prefix
    column_names.map{|c| "plan_categories.#{c}"}.join(",")
  end

  def self.nonempty
    # postgres 8.3 seems to require that the select clause match the group
    # clause.  this is unfortunate, because in local development on
    # postgres 9.1 i can select * and group by id with no problem.
    return joins(:plans)
      .select(columns_with_table_prefix)
      .group(columns_with_table_prefix)
      .having("count(*) > 0")
  end

  def self.reg_form(year, age, events = nil)
    r = yr(year)
      .nonempty
      .where("(age_min is null or age_min <= ?) and (age_max is null or age_max >= ?)", age, age)
      .order(:name)
    r = r.where(event_id: events) unless events.blank?
    return r
  end

  # `first_reg_form_category` returns nil if there are no appropriate categories
  def self.first_reg_form_category(year, attendee, events)
    reg_form(year, attendee.age_in_years, events).first
  end

  # Instance methods, public
  # ------------------------

  def next_reg_form_category(attendee, events)
    PlanCategory.reg_form(self.year, attendee.age_in_years, events)
      .where("plan_categories.name > ?", self.name)
      .first
  end
end
