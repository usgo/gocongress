class Rpt::DailyPlanDetailsReportsController < Rpt::AbstractReportController

  def new
    @daily_plans = daily_plans
  end

  def create
    date_range = AttendeePlanDate.valid_range(@year)
    plan = daily_plans.find(params[:plan_id])
    exporter = DailyPlanDetailsExporter.new(@year, date_range, plan.id)
    send_data exporter.to_csv, filename: csv_filename, type: 'text/csv'
  end

  private

  def csv_filename
    "usgc_daily_plan_details_#{Time.current.strftime("%Y-%m-%d")}.csv"
  end

  def daily_plans
    Plan.yr(@year).daily
  end
end
