class ReportsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  def attendees
    @attendees = Attendee.all
    @attendee_count = Attendee.all.count
    @user_count = User.all.count

    # build csv header line
    cols = []    
    if @attendee_count > 0 then
      cols << Attendee.first.attribute_names_for_csv
      cols << 'user_email'
      claimable_discounts = Discount.where('is_automatic = ?', false).order(:name)
      claimable_discounts.each { |d| cols << "Discount: " + safe_for_csv(d.name) }
    end
    @csv_header_line = cols.join(',')
  end

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
      format.csv do render_csv("usgc_overdue_users_#{Time.now.strftime("%Y-%m-%d")}") end
    end
  end

  def transactions
    @transactions = Transaction.all
    @sales = Transaction.where("trantype = ?", "S")
    @comps = Transaction.where("trantype = ?", "C")
    @refunds = Transaction.where("trantype = ?", "R")
    
    @sales_sum = @sales.sum(:amount)
    @comps_sum = @comps.sum(:amount)
    @refunds_sum = @refunds.sum(:amount)
    @total_sum = @sales_sum - @comps_sum - @refunds_sum

    respond_to do |format|
      format.html do render 'transactions.html.haml' end
      format.csv do render_csv("usgc_transactions_#{Time.now.strftime("%Y-%m-%d")}") end
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

  def safe_for_csv(str)
    str.tr(',"', '')
  end

end
