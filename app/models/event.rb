class Event < ActiveRecord::Base
	attr_accessible :evtname, :evtdeparttime, :evtstarttime, :evtprice, :evtdate
	attr_protected :created_at, :updated_at
  validates_presence_of :evtdate
end
