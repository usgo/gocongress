class Plan < ActiveRecord::Base
attr_accessible :name, :price, :age_min, :age_max, :description, :plan_category_id

belongs_to :plan_category
has_many :attendee_plans, :dependent => :destroy
has_many :users, :through => :attendee_plans

scope :appropriate_for_age, lambda {|age| where("(age_min is null or age_min <= ?) and (age_max is null or age_max >= ?)", age, age)}
scope :room_and_board_page, joins(:plan_category).where('plan_categories.show_on_roomboard_page' => true)
scope :prices_page, joins(:plan_category).where('plan_categories.show_on_prices_page' => true)
scope :reg_form, joins(:plan_category).where('plan_categories.show_on_reg_form' => true)

validates_presence_of :name, :description, :price, :age_min, :plan_category_id
validates_length_of :name, :maximum => 50
validates_numericality_of :price, :greater_than_or_equal_to => 0
validates_numericality_of :age_min, :greater_than_or_equal_to => 0
validates_numericality_of :age_max, :allow_nil => true

def age_range_in_words
  if age_min == 0 && age_max.blank?
    returned_words = "All Ages"
  elsif age_min >= 18
    returned_words = "Adults"
  elsif age_min >= 13
    returned_words = "Teens"
  elsif age_min < 13
    returned_words = "Youth"
  else
    returned_words = "No minimum age"
  end

  if age_min > 0 && age_max.blank?
    returned_words += " (" + age_min.to_s + " and older)"
  elsif age_min == 0 && age_max.present? && age_max > 0
    returned_words += " (" + age_max.to_s + " and younger)"
  elsif age_min > 0 && age_max.present? && age_max > 0
    returned_words += " (" + age_min.to_s + " to " + age_max.to_s + ")"
  end

  return returned_words
end

end
