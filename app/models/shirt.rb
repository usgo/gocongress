class Shirt < ActiveRecord::Base
  include YearlyModel
  has_many :attendees
  attr_accessible :description, :hex_triplet, :image_url, :name

  validates :description,
    :length => { :maximum => 100 },
    :presence => true
  validates :name,
    :length => { :in => 3..40 },
    :presence => true,
    :uniqueness => { :scope => :year }
  validates :hex_triplet,
    :length => { :is => 6 },
    :presence => true,
    :uniqueness => { :scope => :year }
end
