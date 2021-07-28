# Export Players XML for OpenGotha import
class PlayersXmlExporter
  def self.open_gotha_rank(rank_name)
    rank_name.gsub(/ kyu/, 'K').gsub(/ dan/, 'D')
  end

  def self.open_gotha_rating(rank)
    # Adjust dan ranks down one to make up for the fact that we skip a number
    # between -1 and 1
    if rank > 0
      rank -= 1
    end
    base_rating = -900
    base_rating + ((30 + rank) * 100)
  end

  def self.render_player(player, aga_info, username: '')
    xmlTag = {
      agaExpirationDate: aga_info[:expires],
      agaId: username ? '' : player.aga_id,
      firstName: username ? player[username] : player.given_name,
      name: username ? 'X' : player.family_name,
      grade: open_gotha_rank(player.rank_name),
      rank: open_gotha_rank(player.rank_name),
      rating: open_gotha_rating(player.rank),
      club: aga_info[:club]
    }
    str = ""
    xmlTag.each do |attribute, value|
      str += "#{attribute}=\"#{value}\" "
    end
    str = "<Player " + str + "/>"
  end

  def self.render_players(players, aga_info, go_server_username)
    players = players.map { |player| render_player(player, aga_info[player.aga_id.to_s] || {}, username: go_server_username) }
    players.join("\n\t\t")
  end

  def self.render(players, aga_info, go_server_username)
    <<~EOF
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <Tournament dataVersion="201">
        <Players>
          #{render_players(players, aga_info, go_server_username)}
        </Players>
      </Tournament>
    EOF
  end
end
