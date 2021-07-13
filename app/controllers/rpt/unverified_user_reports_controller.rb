class Rpt::UnverifiedUserReportsController < Rpt::AbstractReportController
  def show
    @users = User.yr(@year).where(confirmed_at: nil).order(created_at: :desc)
  end
end
