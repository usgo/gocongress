class Rpt::AttendeeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).with_planlessness(planlessness)
  respond_to do |format|
    format.html do
      @attendee_count = @attendees.count
      @user_count = User.yr(@year).count
      @cancelled_attendee_count = Attendee.yr(@year).attendee_cancelled.count
      @planless_attendee_count = Attendee.yr(@year).planless.count
      @planful_attendee_count = Attendee.yr(@year).count - @planless_attendee_count
      render :show
    end
    format.csv do
      csv = AttendeesCsvExporter.render(@year, @attendees)
      send_data csv, filename: csv_filename, type: 'text/csv'
    end
  end
end

private

def csv_filename
  "usgc_attendees_#{Time.current.strftime("%Y-%m-%d")}.csv"
end

def planlessness
  p = params[:planlessness]
  %w[all planful planless].include?(p) ? p.to_sym : :all
end

end
