class Rpt::DailyPlanDetailsReportsController < Rpt::AbstractReportController

  def show
    respond_to do |format|
      format.html do
        render :show
      end
      format.csv do
        date_range = AttendeePlanDate.valid_range(@year)
        exporter = DailyPlanDetailsExporter.new(@year, date_range)
        send_data exporter.to_csv, filename: csv_filename, type: 'text/csv'
      end
    end
  end

  private

  def csv_filename
    "usgc_daily_plan_details_#{Time.current.strftime("%Y-%m-%d")}.csv"
  end
end
