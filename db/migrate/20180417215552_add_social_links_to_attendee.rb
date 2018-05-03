class AddSocialLinksToAttendee < ActiveRecord::Migration[5.0]
  def change
    add_column :attendees, :social_link_twitter, :string
    add_column :attendees, :social_link_facebook, :string
    add_column :attendees, :social_link_linkedin, :string
    add_column :attendees, :social_link_website, :string
  end
end
