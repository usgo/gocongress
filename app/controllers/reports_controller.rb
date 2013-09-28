class ReportsController < ApplicationController
  include YearlyController

  # Callbacks
  before_filter :deny_users_from_wrong_year
  before_filter :authorize_read_report
  def authorize_read_report() authorize! :read, :report end

  def atn_reg_sheets
    @attendee_attr_names = %w[aga_id birth_date comment email gender phone special_request roomate_request].sort
    @attendees = Attendee.yr(@year) \
      .where('lower(substr(family_name,1,1)) between ? and ?', params[:min], params[:max]) \
      .order('family_name, given_name')
    render :layout => "print"
  end

  def invoices
    users = User.yr(@year).to_a
    @user_count = users.count
    @invoice_total_across_all_users = users.map(&:get_invoice_total).reduce(:+)
  end

  def emails
    @atnd_email_list = ""
    Attendee.yr(@year).each { |a|
      @atnd_email_list += "\"#{a.full_name}\" <#{a.email}>, "
      }
  end

  def activities
    @activities = Activity.yr(@year).order :leave_time
    @activities_by_date = @activities.group_by {|activity| activity.leave_time.to_date}
  end

  def user_invoices
    min = params[:min].downcase
    max = params[:max].downcase
    [min, max].each{ |m| raise "Invalid param" unless ("a".."z").cover?(m) }
    @users = User.yr(@year).email_range(min, max).order(:email).to_a
    render :layout => "print"
  end

protected

  def page_title
    human_action_name.singularize + ' ' + human_controller_name
  end

end
