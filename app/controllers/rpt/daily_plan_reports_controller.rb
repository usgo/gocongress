class Rpt::DailyPlanReportsController < Rpt::AbstractReportController

  def show
    respond_to do |format|
      format.html do
        @num_daily_plans = daily_plans.count
        render :show
      end
      format.csv do
        csv = DailyPlanCsvExporter.new(@year).render
        send_data csv, filename: csv_filename, type: 'text/csv'
      end
    end
  end

  private

  def csv_filename
    "usgc_daily_plans_#{Time.current.strftime("%Y-%m-%d")}.csv"
  end

  def daily_plans
    Plan.yr(@year).daily
  end
end
