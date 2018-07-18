class GameAppointment::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_count, :round_id

  def process!
    round = Round.find(@round_id)
    round_number = round.number.to_s
    doc = Nokogiri::XML(@file)

    # Retrieve an array of appointment hashes (games by specific round) that
    # includes player information, round, table, &c
    appointments = parse_xml(doc, round_number)
    match_aga_numbers(appointments)
    return if !errors.none?
    @imported_count = 0
    appointments.each do |appointment|
      if (appointment['roundNumber'].to_i == round.number)
        game_appointment = GameAppointment::assign_from_hash(round, appointment)
        if game_appointment.save
          @imported_count += 1
        else
          errors.add(:base, "Line #{$.} #{game_appointment.errors.full_messages.join(",")}")
        end
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

  def parse_xml(doc, round_number)
    # TODO: check for errors! Right now we're assuming perfection.

    # Find the players in the XML import
    players = doc.xpath("//Players/Player")
    # Turn the players XML into an array of hashes
    players = players.map{|n| Hash[n.keys.zip(n.values)]}

    # Collect those hashes into an array with key names that match the player
    # names in Open Gotha games
    players = Hash[players.collect {|p| [name_to_key(p), p]}]

    # Find all games for the round being imported (i.e. paired games )
    games = doc.xpath("//Games/Game[@roundNumber=\"#{round_number}\"]")

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

  def match_aga_numbers(appointments)
    appointment_aga_numbers = gather_appoinment_aga_numbers(appointments)
    if appointment_aga_numbers.include?("")
      errors.add(:base, "Please make sure all players in import file have aga id's and resubmit.")
      return
    end
    attendee_aga_numbers = Attendee.gather_aga_numbers
    appointment_aga_numbers.each do |number|
      if attendee_aga_numbers.include?(number)
        next
      else
        errors.add(:base, "There are no attendees with aga id: #{number}")
      end
    end

  end

  def gather_appoinment_aga_numbers(appointments)
    appointments.flat_map do |appointment|
      [appointment["blackPlayer"]["agaId"].to_i, appointment["whitePlayer"]["agaId"].to_i]
    end
  end

end
