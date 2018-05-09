class Round::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_count

  def process!
    doc = Nokogiri::XML(@file)
    # Retrieve a hash of appointments (games without a result yet) that includes
    # player information, round, table, &c
    appointments = parse_xml(doc)
    # TODO: do something with the appointments hash from OpenGotha!
    errors.add(:base, "ERROR")
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
