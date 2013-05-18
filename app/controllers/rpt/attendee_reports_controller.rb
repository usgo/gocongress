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
      @csv_header_line = AttendeesCsvExporter.csv_header_line(@year)
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
