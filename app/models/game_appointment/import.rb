class GameAppointment::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_count, :round_id

  def process!
    round = Round.find(@round_id)
    doc = Nokogiri::XML(@file)

    # Retrieve an array of appointment hashes (games without a result yet) that
    # includes player information, round, table, &c
    appointments = parse_xml(doc)

    @imported_count = 0
    appointments.each do |appointment|
      if (appointment['roundNumber'].to_i == round.number)
        game_appointment = GameAppointment::assign_from_hash(round, appointment)
        if game_appointment.save
          # TODO: Use this imported count somewhere
          @imported_count += 1
        else
          # TODO: Figure out why these errors don't display
          errors.add(:base, "Line #{$.} #{game_appointment.errors.full_messages.join(",")}")
        end
      end
    end
  end

  # OpenGotha has the player names for games as strings with all letters
  # capitalized and spaces stripped
  # e.g. Nate Eagle -> EAGLENATE
  def name_to_key(player)
    [player['name'], player['firstName']].map {
      |name| name.upcase.gsub(/\s+/, "")
    }.join("")
  end

  def parse_xml(doc)
    # TODO: check for errors! Right now we're assuming perfection.

    # Find the players in the XML import
    players = doc.xpath("//Players/Player")

    # Turn the players XML into an array of hashes
    players = players.map{|n| Hash[n.keys.zip(n.values)]}

    # Collect those hashes into an array with key names that match the player
    # names in Open Gotha games
    players = Hash[players.collect {|p| [name_to_key(p), p]}]

    # Find all games with unknown results (i.e. paired games that have not yet
    # been played)
    games = doc.xpath("//Games/Game[@result=\"RESULT_UNKNOWN\"]")

    # Turn the games XML into an array of hashes
    games = games.map{|n| Hash[n.keys.zip(n.values)]}

    # For each game, use the name of the black and white players to populate the
    # hash with player hashes
    games = games.each do |game|
      game['blackPlayer'] = players[game['blackPlayer']]
      game['whitePlayer'] = players[game['whitePlayer']]
    end
    games
  end

  def save
    process!
    errors.none?
  end
end
