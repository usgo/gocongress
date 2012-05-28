class Rpt::AttendeeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year)
  @attendees = case planlessness
    when :planful then @attendees.with_at_least_one_plan
    when :planless then @attendees.with_no_plans
    else @attendees
    end
  @attendees = @attendees.all

  @attendee_count = @attendees.count
  @user_count = User.yr(@year).count

  # build csv header line
  # the order here must match attendee_to_array() in reports_helper.rb
  cols = []
  if @attendee_count > 0 then
    cols << 'user_email'
    cols << @attendees.first.attribute_names_for_csv
    Plan.yr(@year).order(:name).each { |p| cols << "Plan: " + safe_for_csv(p.name) }
    claimable_discounts = Discount.yr(@year).where('is_automatic = ?', false).order(:name)
    claimable_discounts.each { |d| cols << "Discount: " + safe_for_csv(d.name) }
    Tournament.yr(@year).order(:name).each { |t| cols << "Tournament: " + safe_for_csv(t.name) }
  end
  @csv_header_line = cols.join(',')

  respond_to do |format|
    format.html do render :show end
    format.csv do render_csv("usgc_attendees_#{Time.now.strftime("%Y-%m-%d")}") end
  end
end

private

def planlessness
  p = params[:planlessness]
  %w[all planful planless].include?(p) ? p.to_sym : :all
end

end
