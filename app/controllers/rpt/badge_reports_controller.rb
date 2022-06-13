class Rpt::BadgeReportsController < Rpt::AbstractReportController
  def show
    @attendees = Attendee.yr(@year).with_planlessness('planful'.to_sym)
    respond_to do |format|
      format.html do
        render :show
      end

      format.csv do
        headers["X-Accel-Buffering"] = "no"
        headers["Cache-Control"] = "no-cache"
        headers["Content-Type"] = "text/csv; charset=utf-8"
        headers["Content-Disposition"] =
          %(attachment; filename="#{csv_filename}")
        headers["Last-Modified"] = Time.zone.now.ctime.to_s

        self.response_body = BadgeCsvExporter.csv_enumerator(@year, @attendees)
      end
    end
  end

  private

  def csv_filename
    "usgc_badges_#{Time.current.strftime("%Y-%m-%d")}.csv"
  end
end
