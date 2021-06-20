class Insert2013CongressEvent < ActiveRecord::Migration
  EVENT_NAME = 'Congress'

  class Event < ActiveRecord::Base
  end

  def up
    Event.create! :name => EVENT_NAME, :year => 2013
  end

  def down
    e = Event.where("name = ? and year = ?", EVENT_NAME, 2013)
    raise "Expected one event" unless e.count == 1
    e[0].delete
  end
end
