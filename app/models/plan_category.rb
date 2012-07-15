class PlanCategory < ActiveRecord::Base
  include YearlyModel

  belongs_to :event
  has_many :plans

  attr_accessible :description, :event_id, :mandatory, :name

  validates :event, :presence => true
  validates :name, :presence => true,
    :uniqueness => {
      :scope => :year,
      :case_sensitive => false,
      :message => "with that name already exists"
    }
  validates :description, :length => {maximum: 200}

  # Scopes
  # ----------------

  scope :alphabetical, order(:name)
  scope :nonempty, where("exists (select * from plans p
    where p.plan_category_id = plan_categories.id)")

  # Class methods
  # ----------------

  def self.age_appropriate age
    where("exists (select * from plans p
      where p.plan_category_id = plan_categories.id
        and (age_min is null or age_min <= ?)
        and (age_max is null or age_max >= ?)
      )", age, age)
  end

  # `reg_form` defines which categories will appear on the
  # registration form, depending on the year, the age of the
  # attendee, and their events of interest
  def self.reg_form(year, age, events = nil)
    r = yr(year).nonempty.age_appropriate(age).alphabetical
    r = r.where(event_id: events) unless events.blank?
    return r
  end

  # `first_reg_form_category` returns nil if there are no appropriate categories
  def self.first_reg_form_category(year, attendee, events)
    reg_form(year, attendee.age_in_years, events).first
  end

  # Instance methods, public
  # ------------------------

  def attendee_count
    plans.joins(:attendees).count
  end

  def destroy
    if attendee_count > 0
      raise ActiveRecord::DeleteRestrictionError, \
        "Cannot delete, has attendees"
    end
    super
  end

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

  private

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
