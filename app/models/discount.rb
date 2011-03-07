class Discount < ActiveRecord::Base
  validates_presence_of :name, :amount
  validates_numericality_of :amount, :greater_than => 0
  validates_numericality_of :age_min, :only_integer => true, :allow_nil => true
  validates_numericality_of :age_max, :only_integer => true, :allow_nil => true
  validates_inclusion_of :is_automatic, :in => [true, false]
end
