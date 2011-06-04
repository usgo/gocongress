class Event < ActiveRecord::Base
  attr_accessible :evtname, :evtdeparttime, :start, :evtprice, :notes
  validates_presence_of :start, :evtname
end
