class PlanCategory < ApplicationRecord
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

  # Scopes
  # ----------------

  scope :alphabetical, -> { order(:name) }
  scope :mandatory, -> { where(:mandatory => true) }
  scope :nonempty, -> {
    where("exists (
      select * from plans p
      where p.plan_category_id = plan_categories.id
    )")
  }
  scope :single, -> { where(:single => true) }

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

  def reorder_plans ordering
    return unless ordering.present?
    ordering.each do |plan_id, ordinal|
      if ordinal.to_i > 0
        plans.find(plan_id).update_attributes!(:cat_order => ordinal)
      end
    end
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
