require 'open-uri'

class Rpt::UsopenPlayersReportsController < Rpt::AbstractReportController
helper_method :self_promoter

def show
  @players = Attendee.yr(@year)
    .where(:cancelled => false)
    .where(:will_play_in_us_open => true).order('rank DESC')

  @aga_member_info = aga_member_info

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

def self_promoter(player, rating)
  rating = rating.to_f
  rating = player.rank < 1 ? rating.ceil() : rating.floor()

  return player.rank > rating
end

private

def xml_filename
  "usopen_players_#{Time.current.strftime("%Y-%m-%d")}.xml"
end

def aga_member_info_tsv
  Rails.cache.fetch("usgo.org/mm/agagdtdlista.txt", :expires_in => 24.hours) do
    open("https://www.usgo.org/mm/tdlista.txt", "r:UTF-8", &:read)
  end
end

def aga_member_info
  parsed_aga_member_info = {}
  aga_member_info_tsv.each_line do |line|
    values = line.split("\t")
    parsed_aga_member_info[values[1]] = {
      full_name: values[0],
      membership_status: values[2],
      rating: values[3],
      expires: values[4],
      club: values[5],
      state: values[6],
      sigma: values[7],
      last_rated_on: values[8]
    }
  end
  return parsed_aga_member_info
end

end
