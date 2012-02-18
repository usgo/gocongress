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

  # `reorder_plans` takes an array of plans and a corresponding array of
  # their new position numbers.  If unsuccessful it appends some errors
  # to self and returns false.  Otherwise, true.
  def reorder_plans plans, ordering
    ordering_errors = validate_ordering(ordering)
    if ordering_errors.empty?

      # ranked-model position numbers are zero-indexed,
      # so we subtract one from each
      ordering = ordering.map{|x| x - 1}

      # Save new sort order by going through the plans in the same order
      # they appeared before on the show page.
      if ordering.count == plans.count
        plans.each_with_index do |p, ix|
          p.update_attribute :cat_order_position, ordering[ix]
        end
      end
    else
      errors[:base].concat ordering_errors
    end
    return ordering_errors.empty?
  end

  # Private methods
  # ---------------

  def validate_ordering ordering
    ordering_errors = []

    sorted_ordering = ordering.sort
    if sorted_ordering.first != 1
      ordering_errors << "Order must begin with the number one"
    end

    prev = nil
    until sorted_ordering.empty?
      x = sorted_ordering.shift
      if prev.present? && (x - prev != 1)
        ordering_errors << "Order numbers must be sequential"
      end
      prev = x
    end

    ordering_errors
  end

end
