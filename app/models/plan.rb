class Plan < ActiveRecord::Base

validates_presence_of :name, :description, :price, :age_min
validates_length_of :name, :maximum => 50
validates_numericality_of :price, :age_min
validates_numericality_of :age_max, :allow_nil => true

end
