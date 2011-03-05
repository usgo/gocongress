class Tournament < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  has_many :rounds, :dependent => :destroy
  accepts_nested_attributes_for :rounds, :allow_destroy => true
  validates_presence_of :name, :elligible, :description, :directors
end
