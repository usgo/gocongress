require 'csv'

class ReportsController < ApplicationController

  # Access Control
  before_filter :authorize_read_report
  def authorize_read_report() authorize! :read, :report end

  def atn_badges_all
    @attendees = Attendee.yr(@year).where('lower(substr(family_name,1,1)) between ? and ?', params[:min], params[:max])
    @attendees.order('family_name, given_name')
    render :layout => "print"
  end

  def atn_reg_sheets
    @attendee_attr_names = %w[aga_id birth_date comment email gender phone special_request roomate_request].sort
    @attendees = Attendee.yr(@year).where('lower(substr(family_name,1,1)) between ? and ?', params[:min], params[:max])
    @attendees.order('user_id, family_name, given_name')
    @tmt_names = AttendeeTournament.tmt_names_by_attendee(@year.year)
    render :layout => "print"
  end

  def index
  end

  def invoices
    users = User.yr(@year).all
    @user_count = users.count
    @invoice_total_across_all_users = users.map(&:get_invoice_total).reduce(:+)
  end

  def emails
    @atnd_email_list = ""
    Attendee.yr(@year).each { |a|
      @atnd_email_list += "\"#{a.get_full_name}\" <#{a.email}>, "
      }
  end

  def activities
    @activities = Activity.yr(@year).order :leave_time
    @activities_by_date = @activities.group_by {|activity| activity.leave_time.to_date}
  end

  def outstanding_balances
    @users = User.yr(@year).includes(User::EAGER_LOAD_CONFIG_FOR_INVOICES)

    # Keep users with non-zero balances.  Obviously, we want to see
    # users who owe us money, but it is also useful for the registrar
    # to see people who deserve refunds.
    @users.keep_if { |u| u.balance >= 0.01 || u.balance <= -0.01 }

    # Sort by family_name.  Normally we would do this in the query,
    # but joining on primary_attendee would conflict with our eager
    # loading configuration.
    @users.sort!{|a,b| a.primary_attendee.family_name <=> b.primary_attendee.family_name}
  end

  def transactions
    @transactions = Transaction.yr(@year).all
    @sales = Transaction.yr(@year).where("trantype = ?", "S")
    @comps = Transaction.yr(@year).where("trantype = ?", "C")
    @refunds = Transaction.yr(@year).where("trantype = ?", "R")

    @sales_sum = @sales.sum(:amount)
    @comps_sum = @comps.sum(:amount)
    @refunds_sum = @refunds.sum(:amount)
    @total_sum = @sales_sum - @comps_sum - @refunds_sum

    respond_to do |format|
      format.html do render :transactions end
      format.csv do render_csv("usgc_transactions_#{Time.now.strftime("%Y-%m-%d")}") end
    end
  end

  def tournaments
    # Lisa wants "the US Open at the bottom, since it will be by far the longest"
    @tournaments = Tournament.yr(@year).order("name <> 'US Open' desc, name asc")
  end

  def user_invoices
    min = params[:min].downcase
    max = params[:max].downcase
    [min, max].each{ |m| raise "Invalid param" unless ("a".."z").cover?(m) }
    @users = User.yr(@year).pri_att_fam_name_range(min, max) \
      .order('family_name, given_name').all
    render :layout => "print"
  end

protected

  def page_title
    human_action_name.singularize + ' ' + human_controller_name
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
