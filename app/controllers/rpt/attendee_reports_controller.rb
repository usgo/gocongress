class Rpt::AttendeeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).all
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

end
