class Plan < ActiveRecord::Base

validates_presence_of :name, :description, :price, :age_min
validates_numericality_of :price, :age_min
validates_numericality_of :age_max, :allow_nil => true

end
