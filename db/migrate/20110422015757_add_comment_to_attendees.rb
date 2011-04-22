class AddCommentToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :comment, :string
  end

  def self.down
    remove_column :attendees, :comment
  end
end
