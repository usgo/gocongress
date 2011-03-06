class UpdateTshirtSizeAgain < ActiveRecord::Migration
  def self.up
    Attendee.update_all :tshirt_size => 'NO'
  end

  def self.down
    raise IrreversibleMigration
  end
end
