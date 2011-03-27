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

  def overdue_deposits
    @overdue_users = []
    User.all.each { |u|
      is_deposit_paid = u.get_num_attendee_deposits_paid == u.attendees.count
      is_past_deposit_due_date = u.get_initial_deposit_due_date < Time.now.to_date
      if (is_past_deposit_due_date && !is_deposit_paid) then
        @overdue_users << u
      end
    }
    respond_to do |format|
      format.html do render 'overdue_deposits.html.haml' end
      format.csv do render_csv("overdue_users_#{Time.now.strftime("%Y-%m-%d")}") end
    end
  end

private

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'
  
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end
  
    render :layout => false
  end

end
