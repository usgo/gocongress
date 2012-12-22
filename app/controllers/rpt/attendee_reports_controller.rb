class Rpt::AttendeeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).with_planlessness(planlessness)
  respond_to do |format|
    format.html do
      @attendee_count = @attendees.count
      @user_count = User.yr(@year).count
      @planless_attendee_count = Attendee.yr(@year).planless.count
      @planful_attendee_count = Attendee.yr(@year).count - @planless_attendee_count
      render :show
    end
    format.csv do
      @csv_header_line = csv_header_line
      render_csv("usgc_attendees_#{Time.now.strftime("%Y-%m-%d")}")
    end
  end
end

private

# The order of `csv_header_line` must match
# `attendee_to_array` in `reports_helper.rb`
def csv_header_line
  atrs = Attendee.attribute_names_for_csv
  plans = Plan.yr(@year).order(:name).map{ |p| "Plan: " + safe_for_csv(p.name)}
  (['user_email'] + atrs + plans).join(',')
end

def planlessness
  p = params[:planlessness]
  %w[all planful planless].include?(p) ? p.to_sym : :all
end

end
