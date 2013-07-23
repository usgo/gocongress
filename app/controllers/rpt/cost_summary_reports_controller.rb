class Rpt::CostSummaryReportsController < Rpt::AbstractReportController

  def show
    respond_to do |format|
      format.html do
        @user_count = User.yr(@year).count
        @attendee_count = Attendee.yr(@year).count
      end
      format.csv do
        csv = CostSummariesExporter.new(@year).to_csv
        send_data csv, filename: csv_filename, type: 'text/csv'
      end
    end
  end

  private

  def csv_filename
    "usgc_cost_summaries_#{Date.current.strftime("%Y-%m-%d")}.csv"
  end

end
