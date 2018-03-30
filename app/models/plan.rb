class Plan < ApplicationRecord
  include YearlyModel
  include Purchasable

# Associations
# ------------

belongs_to :plan_category
has_many :attendee_plans, :dependent => :restrict_with_exception
has_many :attendees, :through => :attendee_plans

# Validations
# -----------

validates_each :daily do |record, atr, value|
  if value && record.needs_staff_approval?
    record.errors.add(atr, " and 'needs staff approval' are
      mutally exclusive")
  end
end

validates :disabled, :inclusion => { :in => [true, false] }
validates :show_disabled, :inclusion => { :in => [true, false] }
validates_presence_of :name, :description, :price, :age_min, :plan_category_id
validates_length_of :name, :maximum => 50
validates_numericality_of :age_min, :only_integer => true, :greater_than_or_equal_to => 0
validates_numericality_of :age_max, :only_integer => true, :allow_nil => true

validates :max_quantity, :presence => true, :numericality => {:only_integer => true}
validates :max_quantity, :numericality => {:greater_than_or_equal_to => 1}, :unless => :daily?
validates :max_quantity,
  :numericality => {
    :equal_to => 1,
    :message => 'for daily-rate plans must be 1 (one)'
  },
  :if => :daily?

validates :inventory,
  :numericality => {
    :only_integer => true, :greater_than => 0, :allow_nil => true,
    :message => " should be greater than 0 or left blank if unlimited"
    }

validates_each :inventory do |record, attr, value|
  cnt = record.attendees.where(cancelled: false).count
  if value.present? && value < cnt
    record.errors.add(attr, " cannot be decreased to #{value} because
      #{cnt} #{Attendee.model_name.human.pluralize.downcase} have
      already selected this #{Plan.model_name.human.downcase}.")
  end
end

validates :needs_staff_approval, :inclusion => { :in => [true, false] }

validates_each :price do |record, attr, value|
  if record.needs_staff_approval? && record.price != 0.0
    record.errors.add(attr, " must be zero for plans that need
      staff approval (see instructions).")
  end
end

# Scopes
# ------

scope :appropriate_for_age, lambda { |age|
  where("(age_min is null or age_min <= ?) and (age_max is null or age_max >= ?)", age, age)
}
scope :alphabetical, -> { order(:name) }
scope :enabled, -> { where(disabled: false) }

# Class Methods
# -------------

def self.daily
  where daily: true
end

# `inventoried_plan_in?` returns true if the supplied plan array
# contains at least one plan with an inventory.
def self.inventoried_plan_in? plans
  plans.map{|p| p.inventory.present?}.include? true
end

# `quantifiable_plan_in?` returns true if the supplied plan array
# contains at least one plan with a max_quantity > 1.
def self.quantifiable_plan_in? plans
  plans.map{|p| p.max_quantity > 1}.include? true
end

# Public Instance Methods
# -----------------------

def age_range_in_words
  if age_min == 0 && age_max.blank?
    return "All Ages"
  else
    return age_min.to_s + (age_max.blank? ? " and up" : " to #{age_max}")
  end
end

def describe_inventory_available
  inventory.present? ? "#{inventory_available} of #{inventory}" : "Unlimited"
end

def inventory_cancelled
  attendee_plans.joins(:attendee).where(attendees: { cancelled: true }).sum(:quantity)
end

def inventory_consumed(excluded_attendee=nil)
  attendee_plans_except(excluded_attendee).sum(:quantity)
end

def inventory_available(excluded_attendee=nil)
  return nil if inventory.nil?
  c = inventory_consumed(excluded_attendee)
  n = inventory_cancelled
  c - n > inventory ? 0 : inventory + n - c
end

private

def attendee_plans_except(atnd=nil)
  if atnd.nil? || atnd.new_record?
    attendee_plans
  else
    attendee_plans.where('attendee_id <> ?', atnd.id)
  end
end

end
