class ReportsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  def index
  end

  def emails
    @atnd_email_list = ""
    Attendee.all.each { |a|
      @atnd_email_list += "\"#{a.get_full_name}\" <#{a.email}>, "
      }
  end

end
