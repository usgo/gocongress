class Event < ActiveRecord::Base
  attr_accessible :evtname, :evtdeparttime, :start, :evtprice, :notes, \
    :return_depart_time, :return_arrive_time
  validates_presence_of :start, :evtname
end
