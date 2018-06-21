class Rpt::BadgeReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).with_planlessness('planful'.to_sym)
  respond_to do |format|
    format.html do
      render :show
    end

    format.csv do
      csv = BadgeCsvExporter.render(@year, @attendees)
      send_data csv, filename: csv_filename, type: 'text/csv'
    end
  end
end

private

def csv_filename
  "usgc_badges_#{Time.current.strftime("%Y-%m-%d")}.csv"
end

end
