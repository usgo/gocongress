class Tournament < ActiveRecord::Base

has_many :rounds, :dependent => :destroy
accepts_nested_attributes_for :rounds, :allow_destroy => true

validates_presence_of :name, :elligible, :description, :directors

end
