class Round::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_game_count, :imported_bye_count, :round_id

  def initialize(file:, imported_game_count: 0, imported_bye_count: 0, round_id:)
    @imported_game_count = imported_game_count
    @imported_bye_count = imported_bye_count
    @round_id = round_id
    @file = file
  end

  def process!
    round = Round.find(round_id)
    round_number = round.number.to_s
    doc = Nokogiri::XML(file)
    players = get_players(doc)

    match_aga_numbers(players)
    return if errors.any?

    game_appointments = parse_xml_for_games(doc, players, round_number)
    bye_appointments = parse_xml_for_byes(doc, players, round_number)

    game_appointments.each do |appointment|
      game_appointment = GameAppointment::assign_from_hash(round, appointment)
      if !game_appointment
        errors.add(:base, "Line #{$.} caused a game error.")
      elsif game_appointment.save
        @imported_game_count += 1
      else
        errors.add(:base, "Line #{$.} caused a game error: #{game_appointment.errors.full_messages.join(", ")}")
      end
    end

    bye_appointments.each do |bye|
      bye_appointment = ByeAppointment.assign_from_hash(round, bye)
      if bye_appointment.save
        @imported_bye_count += 1
      else
        errors.add(:base, "Line #{$.} caused a bye error: #{bye_appointment.errors.full_messages.join(", ")}")
      end
    end

  end

  def save
    process!
    errors.none?
  end

  private
  # OpenGotha has the player names for games as strings with all letters
  # capitalized and spaces stripped
  # e.g. Nate Eagle -> EAGLENATE
  def name_to_key(player)
    [player['name'], player['firstName']].map {
      |name| name.upcase.gsub(/\s+/, "")
    }.join("")
  end

  def parse_xml_for_games(doc, players, round_number)
    # TODO: check for errors! Right now we're assuming perfection.
    games = get_games(doc, round_number)
    # For each game, use the name of the black and white players to populate the
    # hash with player hashes
    games = games.each do |game|
      game['blackPlayer'] = players[game['blackPlayer']]
      game['whitePlayer'] = players[game['whitePlayer']]
    end
    games
  end

  def parse_xml_for_byes(doc, players, round_number)
    byes = get_byes(doc, round_number)
    byes = byes.each do |bye|
      bye[:attendee] = players[bye['player']]
    end
    byes
  end

  def get_games(doc, round_number)
    games = doc.xpath("//Games/Game[@roundNumber=\"#{round_number}\"]")

    # Turn the games XML into an array of hashes
    games = games.map{|n| Hash[n.keys.zip(n.values)]}
    games
  end

  def get_byes(doc, round_number)
    byes = doc.xpath("//ByePlayers/ByePlayer[@roundNumber=\"#{round_number}\"]")
    byes = byes.map{|n| Hash[n.keys.zip(n.values)]}
    byes
  end

  def get_players(doc)
    players = doc.xpath("//Players/Player")
    # Turn the players XML into an array of hashes
    players = players.map{|n| Hash[n.keys.zip(n.values)]}

    # Collect those hashes into an array with key names that match the player
    # names in Open Gotha games
    players = Hash[players.collect {|p| [name_to_key(p), p]}]

    players

  end

  def match_aga_numbers(players)
    players_aga_numbers = gather_player_aga_numbers(players)
    if players_aga_numbers.include?("")
      errors.add(:base, "Please make sure all players in import file have AGA IDs and resubmit.")
      return
    end

    attendee_aga_numbers = Attendee.gather_aga_numbers
    players_aga_numbers.each do |number|
      if attendee_aga_numbers.include?(number)
        next
      else
        errors.add(:base, "There are no attendees with aga id: #{number}")
      end
    end

  end

  def gather_player_aga_numbers(players)
    player_aga_ids = []
    players.each do |player, value|
      player_aga_ids << value["agaId"].to_i
    end
    player_aga_ids
  end

end
