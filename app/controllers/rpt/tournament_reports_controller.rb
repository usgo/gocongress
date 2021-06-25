require 'open-uri'

class Rpt::TournamentReportsController < Rpt::AbstractReportController
  def show
    @tournament = Tournament.yr(@year).find(params[:id])
    @page_title = @tournament.name

    @players = @tournament.attendees

    @aga_member_info = AgaTdList.data

    respond_to do |format|
      format.html do
        @players_count = @players.count
        render :show
      end
      format.xml do
        xml = PlayersXmlExporter.render(@players, @aga_member_info)
        send_data xml, filename: xml_filename, type: 'text/xml'
      end
    end
  end

  def xml_filename
    "#{helpers.slugify(@tournament.name, '_')}_players_#{Time.current.strftime('%Y-%m-%d')}.xml"
  end
end
