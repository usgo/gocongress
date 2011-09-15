class PlanCategory < ActiveRecord::Base
  has_many :plans
  validates_presence_of :name, :year
  validates_inclusion_of :show_on_prices_page, :in => [true, false]
  validates_inclusion_of :show_on_reg_form, :in => [true, false]
  validates_inclusion_of :show_on_roomboard_page, :in => [true, false]
  validates_numericality_of :year, :only_integer => true, :greater_than => 2010, :less_than => 2100

  # Scopes, and class methods that act like scopes
  def self.yr(year) where(:year => year) end
end
