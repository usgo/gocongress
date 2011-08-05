class Content < ActiveRecord::Base
  validates_presence_of :subject, :body
  validates_length_of :subject, :maximum => 100
  validates_inclusion_of :show_on_homepage, :in => [true, false]
  validates_datetime :expires_at, :allow_blank => true
end
