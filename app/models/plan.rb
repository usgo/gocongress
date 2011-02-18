class Plan < ActiveRecord::Base

validates_presence_of :name, :description, :price, :age_min
validates_length_of :name, :maximum => 50
validates_numericality_of :price, :age_min
validates_numericality_of :age_max, :allow_nil => true

# A plan with neither rooms nor meals is invalid.  This is implemented
# by PlanFlagValidator (found in lib/).  Notice the naming convention
# between plan_flag and PlanFlagValidator. -Jared 2011.02.18
validates :has_rooms, :plan_flag => true
validates :has_meals, :plan_flag => true

end
