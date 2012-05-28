class Rpt::AttendeeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).with_planlessness(planlessness)
  @attendee_count = @attendees.count

  respond_to do |format|
    format.html do
      @user_count = User.yr(@year).count
      @planless_attendee_count = Attendee.yr(@year).planless.count
      @planful_attendee_count = Attendee.yr(@year).count - @planless_attendee_count
      render :show
    end
    format.csv do
      # Build csv header line.  The order must match
      # attendee_to_array() in reports_helper.rb
      cols = ['user_email'].concat Attendee.attribute_names_for_csv
      Plan.yr(@year).order(:name).each { |p| cols << "Plan: " + safe_for_csv(p.name) }
      claimable_discounts = Discount.yr(@year).where('is_automatic = ?', false).order(:name)
      claimable_discounts.each { |d| cols << "Discount: " + safe_for_csv(d.name) }
      Tournament.yr(@year).order(:name).each { |t| cols << "Tournament: " + safe_for_csv(t.name) }
      @csv_header_line = cols.join(',')
      render_csv("usgc_attendees_#{Time.now.strftime("%Y-%m-%d")}")
    end
  end
end

private

def planlessness
  p = params[:planlessness]
  %w[all planful planless].include?(p) ? p.to_sym : :all
end

end
