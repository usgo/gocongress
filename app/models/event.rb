class Event < ActiveRecord::Base
  attr_accessible :evtname, :evtdeparttime, :evtstarttime, :evtprice, :evtdate
  validates_presence_of :evtdate, :evtname
end
