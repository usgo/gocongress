class Attendee < ActiveRecord::Base
  belongs_to :user

  # TODO: Add Validation for gender
  # TODO: Add Validation for rank

  RANKS = []
  109.downto(101).each {|r| RANKS << ["#{r-100} pro", r] }
  8.downto(1).each {|r| RANKS << [ "#{r} dan", r] }
  -1.downto(-30).each {|r| RANKS << ["#{-r} kyu", r] }
end
