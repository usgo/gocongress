require 'open-uri'

class Rpt::TournamentReportsController < Rpt::AbstractReportController
  def show
    @tournament = Tournament.yr(@year).find(params[:id])
    @page_title = @tournament.name

    @players = @tournament.attendees
  end
end
