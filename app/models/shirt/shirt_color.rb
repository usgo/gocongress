class Shirt::ShirtColor < ActiveRecord::Base
  include YearlyModel
  has_many :attendees
  attr_accessible :name, :hex_triplet
  validates :name,
    :length => { :in => 3..30 },
    :presence => true,
    :uniqueness => { :scope => :year }
  validates :hex_triplet,
    :length => { :is => 6 },
    :presence => true,
    :uniqueness => { :scope => :year }
end
