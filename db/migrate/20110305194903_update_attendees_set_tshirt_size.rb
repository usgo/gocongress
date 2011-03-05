class UpdateAttendeesSetTshirtSize < ActiveRecord::Migration
  class Attendee < ActiveRecord::Base
  end

  def self.up
    Attendee.update_all :tshirt_size => 'no'
  end

  def self.down
    raise IrreversibleMigration
  end
end
