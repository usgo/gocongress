class Plan < ActiveRecord::Base
  include YearlyModel

attr_accessible :name, :price, :age_min, :age_max, :description, \
  :inventory, :max_quantity, :plan_category_id

# FIXME: in the controller, somehow year needs to get set
# before authorize! runs.  until then, year needs to be accessible.
attr_accessible :year

# Associations
# ------------

belongs_to :plan_category
has_many :attendee_plans, :dependent => :destroy
has_many :attendees, :through => :attendee_plans

# Validations
# -----------

validates_presence_of :name, :description, :price, :age_min, :plan_category_id
validates_length_of :name, :maximum => 50
validates_numericality_of :price, :greater_than_or_equal_to => 0
validates_numericality_of :age_min, :only_integer => true, :greater_than_or_equal_to => 0
validates_numericality_of :age_max, :only_integer => true, :allow_nil => true

validates :max_quantity,
  :presence => true,
  :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}

validates :inventory,
  :numericality => {
    :only_integer => true, :greater_than => 0, :allow_nil => true,
    :message => " should be greater than 0 or left blank if unlimited"
    }

# Scopes
# ------

scope :appropriate_for_age, lambda {|age| where("(age_min is null or age_min <= ?) and (age_max is null or age_max >= ?)", age, age)}
scope :alphabetical, order(:name)

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

def inventory_consumed(excluded_attendee=nil)
  ap = attendee_plans
  ap.where('attendee_id <> ?', excluded_attendee.id) if excluded_attendee.present?
  ap.sum(:quantity)
end

def inventory_available(excluded_attendee=nil)
  return nil if inventory.nil?
  c = inventory_consumed(excluded_attendee)
  c > inventory ? 0 : inventory - c
end

def self.show_availability?(plans)
  plans.map{|p| p.inventory.present?}.reduce{|disj, n| disj || n}
end

end
